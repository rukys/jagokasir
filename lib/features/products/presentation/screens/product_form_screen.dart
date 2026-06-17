import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/sku_generator.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';

/// Screen tambah/edit produk.
/// [product] null = mode tambah, non-null = mode edit.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});
  final ProductEntity? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _skuCtrl;
  late final TextEditingController _sellingPriceCtrl;
  late final TextEditingController _costPriceCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _barcodeCtrl;

  String? _selectedCategoryId;
  String? _imagePath;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _skuCtrl = TextEditingController(text: p?.sku ?? '');
    _sellingPriceCtrl = TextEditingController(
      text: p?.sellingPrice != null ? p!.sellingPrice.toStringAsFixed(0) : '',
    );
    _costPriceCtrl = TextEditingController(
      text: p?.costPrice != null ? p!.costPrice!.toStringAsFixed(0) : '',
    );
    _unitCtrl = TextEditingController(text: p?.unit ?? 'pcs');
    _barcodeCtrl = TextEditingController(text: p?.barcode ?? '');
    _selectedCategoryId = p?.categoryId ?? 'cat-uncategorized';
    _imagePath = p?.imagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _costPriceCtrl.dispose();
    _unitCtrl.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }

  void _autoGenerateSku() {
    final name = _nameCtrl.text.trim();
    setState(
      () => _skuCtrl.text =
          name.isNotEmpty ? SkuGenerator.generate(name) : SkuGenerator.generate('PRD'),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => const _BarcodeScannerScreen(),
      ),
    );
    if (result != null) {
      setState(() => _barcodeCtrl.text = result);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final sellingPrice =
        double.tryParse(_sellingPriceCtrl.text.replaceAll(',', '.')) ?? 0.0;

    // Konfirmasi jika harga 0
    if (sellingPrice == 0) {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: 'Produk Gratis?',
        message: 'Harga jual 0 berarti produk ini gratis. Lanjutkan?',
        confirmText: 'Ya, Lanjutkan',
      );
      if (confirmed != true) return;
    }

    final costPrice =
        _costPriceCtrl.text.trim().isNotEmpty
            ? double.tryParse(_costPriceCtrl.text.replaceAll(',', '.'))
            : null;

    LoadingOverlay.show(context, message: 'Menyimpan produk...');

    final success = await ref.read(productFormNotifierProvider.notifier).save(
      id: isEditing ? widget.product!.id : null,
      name: _nameCtrl.text.trim(),
      sku: _skuCtrl.text.trim().isNotEmpty ? _skuCtrl.text.trim() : null,
      sellingPrice: sellingPrice,
      costPrice: costPrice,
      categoryId:
          _selectedCategoryId ?? 'cat-uncategorized',
      unit: _unitCtrl.text.trim(),
      barcode:
          _barcodeCtrl.text.trim().isNotEmpty ? _barcodeCtrl.text.trim() : null,
      imagePath: _imagePath,
    );

    if (!mounted) return;
    LoadingOverlay.hide(context);

    if (success) {
      ErrorSnackbar.showSuccess(
        context,
        isEditing ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan',
      );
      context.pop();
    } else {
      final errMsg = ref.read(productFormNotifierProvider.notifier).errorMessage;
      ErrorSnackbar.showError(context, errMsg ?? 'Gagal menyimpan produk');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Produk' : 'Tambah Produk'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Simpan'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto produk
              _buildImagePicker(theme),
              const SizedBox(height: AppSpacing.xxl),

              // Nama*
              AppTextField(
                label: 'Nama Produk*',
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // SKU + auto-gen
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'SKU',
                      hint: 'Otomatis jika kosong',
                      controller: _skuCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: OutlinedButton(
                      onPressed: _autoGenerateSku,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, AppSpacing.buttonHeight),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                      ),
                      child: const Text('Auto'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Harga jual*
              AppTextField(
                label: 'Harga Jual*',
                controller: _sellingPriceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                textInputAction: TextInputAction.next,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text('Rp', style: TextStyle(color: AppColors.onSurface)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Harga jual wajib diisi';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Harga modal
              AppTextField(
                label: 'Harga Modal (opsional)',
                controller: _costPriceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                textInputAction: TextInputAction.next,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text('Rp', style: TextStyle(color: AppColors.onSurface)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Kategori dropdown
              _buildCategoryDropdown(theme, categoriesAsync),
              const SizedBox(height: AppSpacing.lg),

              // Satuan
              AppTextField(
                label: 'Satuan*',
                hint: 'pcs, kg, liter, dll',
                controller: _unitCtrl,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Satuan tidak boleh kosong' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Barcode + scan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Barcode (opsional)',
                      controller: _barcodeCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: OutlinedButton(
                      onPressed: _scanBarcode,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, AppSpacing.buttonHeight),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Tombol simpan
              AppButton(
                label: isEditing ? 'Simpan Perubahan' : 'Tambah Produk',
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return Center(
      child: GestureDetector(
        onTap: () => _showImagePickerModal(),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: _imagePath != null && File(_imagePath!).existsSync()
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(_imagePath!), fit: BoxFit.cover),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppSpacing.radiusSm),
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.onPrimary,
                            size: AppSpacing.iconSizeSm,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: AppSpacing.iconSizeLg,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tambah Foto',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showImagePickerModal() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text(
                  'Hapus Foto',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagePath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(
    ThemeData theme,
    AsyncValue<List<dynamic>> categoriesAsync,
  ) {
    return categoriesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
      data: (cats) {
        // Deduplicate berdasarkan id — menghindari crash jika ada data ganda.
        final seen = <String>{};
        final unique = cats.cast<dynamic>().where((c) {
          final id = c.id as String;
          return seen.add(id);
        }).toList();

        // Pastikan ada fallback jika list kosong
        if (unique.isEmpty) {
          return const SizedBox.shrink();
        }

        // Pastikan nilai terpilih ada di list; fallback ke item pertama.
        final validIds = unique.map((c) => c.id as String).toSet();
        if (_selectedCategoryId != null &&
            !validIds.contains(_selectedCategoryId)) {
          // Gunakan post-frame callback agar tidak setState saat build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedCategoryId = unique.first.id as String);
            }
          });
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedCategoryId != null && validIds.contains(_selectedCategoryId)
              ? _selectedCategoryId
              : unique.first.id as String,
          decoration: const InputDecoration(
            labelText: 'Kategori',
          ),
          items: unique.map((c) {
            return DropdownMenuItem<String>(
              value: c.id as String,
              child: Text(c.name as String),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategoryId = val),
        );
      },
    );
  }
}

// ── Barcode Scanner Screen ────────────────────────────────────────────────────

class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  bool _isScanned = false;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_isScanned) return;
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue != null) {
                _isScanned = true;
                Navigator.pop(context, barcode!.rawValue);
              }
            },
          ),
          // Overlay guide
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke barcode',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                shadows: [const Shadow(blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
