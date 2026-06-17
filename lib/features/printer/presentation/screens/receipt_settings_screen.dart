// lib/features/printer/presentation/screens/receipt_settings_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../providers/store_config_provider.dart';

class ReceiptSettingsScreen extends ConsumerStatefulWidget {
  const ReceiptSettingsScreen({super.key});

  @override
  ConsumerState<ReceiptSettingsScreen> createState() => _ReceiptSettingsScreenState();
}

class _ReceiptSettingsScreenState extends ConsumerState<ReceiptSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text inputs
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _footerController = TextEditingController();

  // Settings
  String? _logoPath;
  bool _isAutoPrint = true;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  // ── Logo Pickers ───────────────────────────────────────────────────────────

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400);

      if (image != null) {
        setState(() {
          _logoPath = image.path;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar logo: $error')),
        );
      }
    }
  }

  void _removeLogo() {
    setState(() {
      _logoPath = null;
    });
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(storeConfigMaintenanceProvider.notifier);
    final success = await notifier.updateConfig(
      storeName: _nameController.text.trim(),
      storeAddress: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      storePhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      receiptFooter: _footerController.text.trim().isNotEmpty ? _footerController.text.trim() : null,
      logoPath: _logoPath,
      autoPrint: _isAutoPrint,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan struk berhasil disimpan')),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(storeConfigMaintenanceProvider).maybeWhen(
              error: (err, _) => err.toString(),
              orElse: () => 'Gagal menyimpan pengaturan',
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.danger, content: Text(error)),
        );
      }
    }
  }

  void _showPreviewDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _ReceiptPreviewDialog(
        storeName: _nameController.text.trim().isEmpty ? 'TOKO SAYA' : _nameController.text.trim(),
        storeAddress: _addressController.text.trim(),
        storePhone: _phoneController.text.trim(),
        receiptFooter: _footerController.text.trim(),
        logoPath: _logoPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(storeConfigProvider);
    final maintenanceState = ref.watch(storeConfigMaintenanceProvider);
    final theme = Theme.of(context);

    // Initial form filling when data is loaded
    ref.listen(storeConfigProvider, (_, next) {
      next.whenData((config) {
        if (_nameController.text.isEmpty) {
          _nameController.text = config.storeName;
          _addressController.text = config.storeAddress ?? '';
          _phoneController.text = config.storePhone ?? '';
          _footerController.text = config.receiptFooter ?? '';
          _logoPath = config.logoPath;
          _isAutoPrint = config.autoPrint;
          setState(() {});
        }
      });
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Pengaturan Struk'),
            elevation: 0,
            foregroundColor: AppColors.onBackground,
            backgroundColor: Colors.transparent,
          ),
          body: configAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text('Gagal memuat pengaturan: $err', style: const TextStyle(color: AppColors.danger)),
              ),
            ),
            data: (config) {
              // Populate inputs on first load if they are empty
              if (_nameController.text.isEmpty && config.storeName.isNotEmpty) {
                _nameController.text = config.storeName;
                _addressController.text = config.storeAddress ?? '';
                _phoneController.text = config.storePhone ?? '';
                _footerController.text = config.receiptFooter ?? '';
                _logoPath = config.logoPath;
                _isAutoPrint = config.autoPrint;
              }

              return Form(
                key: _formKey,
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      // Store Logo Picker Section
                      _buildLogoPickerCard(theme),
                      const SizedBox(height: AppSpacing.md),

                      // Store Identity Fields Card
                      _buildIdentityCard(theme),
                      const SizedBox(height: AppSpacing.md),

                      // Printing Behavior Card
                      _buildBehaviorCard(theme),
                      const SizedBox(height: AppSpacing.xxl),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.preview_rounded),
                              label: const Text('Preview Struk'),
                              onPressed: _showPreviewDialog,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('Simpan'),
                              onPressed: _saveSettings,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            );
            },
          ),
        ),
        if (maintenanceState is AsyncLoading)
          const LoadingOverlay(message: 'Menyimpan pengaturan...'),
      ],
    );
  }

  Widget _buildLogoPickerCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logo Toko / Struk',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Akan dicetak di bagian paling atas struk (dalam hitam putih).',
              style: TextStyle(fontSize: 11, color: AppColors.outline),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                // Image preview box
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: _logoPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.file(
                            File(_logoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded, color: AppColors.danger),
                          ),
                        )
                      : const Icon(Icons.image_outlined, color: AppColors.outline, size: 32),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Button actions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        icon: const Icon(Icons.photo_library_rounded, size: 16),
                        label: const Text('Pilih Logo Galeri', style: TextStyle(fontSize: 12)),
                        onPressed: _pickLogo,
                      ),
                      if (_logoPath != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            foregroundColor: AppColors.danger,
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16),
                          label: const Text('Hapus Logo', style: TextStyle(fontSize: 12)),
                          onPressed: _removeLogo,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Identitas Toko di Struk',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Toko*',
                hintText: 'Masukkan nama usaha Anda',
                prefixIcon: Icon(Icons.storefront_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Nama toko tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat Toko (Opsional)',
                hintText: 'Contoh: Jl. Merdeka No. 45, Bandung',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon (Opsional)',
                hintText: 'Contoh: 081234567890',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _footerController,
              decoration: const InputDecoration(
                labelText: 'Footer Struk (Opsional)',
                hintText: 'Contoh: Barang yang dibeli tidak dapat ditukar',
                prefixIcon: Icon(Icons.sticky_note_2_outlined),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorCard(ThemeData theme) {
    return Card(
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        value: _isAutoPrint,
        onChanged: (val) {
          setState(() {
            _isAutoPrint = val;
          });
        },
        title: Text(
          'Cetak Struk Otomatis',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Struk fisik akan otomatis langsung dicetak setelah kasir menyelesaikan proses transaksi checkout.',
          style: TextStyle(fontSize: 11, color: AppColors.outline),
        ),
      ),
    );
  }
}

// ── Visual Struk Preview Dialog ──────────────────────────────────────────────

class _ReceiptPreviewDialog extends StatelessWidget {
  const _ReceiptPreviewDialog({
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.receiptFooter,
    this.logoPath,
  });

  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String receiptFooter;
  final String? logoPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xxl),
      child: Container(
        width: width.clamp(280.0, 360.0),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Preview Struk',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Thermal paper preview representation
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      if (logoPath != null) ...[
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(logoPath!),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      // Store Info Header
                      Center(
                        child: Text(
                          storeName.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (storeAddress.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          storeAddress.trim(),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (storePhone.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Telp: ${storePhone.trim()}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: AppSpacing.sm),
                      const Text('- - - - - - - - - - - - - - - -', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'monospace', color: AppColors.outlineVariant)),
                      const SizedBox(height: AppSpacing.sm),

                      // Meta
                      _buildMetaRow('Invoice', 'INV-20260611-0001'),
                      _buildMetaRow('Tanggal', '11/06/2026 15:30'),
                      _buildMetaRow('Kasir', 'Budi Kasir'),

                      const SizedBox(height: AppSpacing.sm),
                      const Text('- - - - - - - - - - - - - - - -', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'monospace', color: AppColors.outlineVariant)),
                      const SizedBox(height: AppSpacing.sm),

                      // Sample Items
                      _buildItemRow('Kopi Susu Gula Aren', '2 x Rp 15.000', 'Rp 30.000'),
                      _buildItemRow('Roti Bakar Keju Coklat', '1 x Rp 18.000', 'Rp 18.000'),
                      const _DottedLine(),
                      _buildItemRow('Diskon Kopi (5%)', '', '-Rp 1.500', isDisc: true),

                      const SizedBox(height: AppSpacing.sm),
                      const Text('- - - - - - - - - - - - - - - -', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'monospace', color: AppColors.outlineVariant)),
                      const SizedBox(height: AppSpacing.sm),

                      // Totals
                      _buildMetaRow('Subtotal', 'Rp 46.500'),
                      _buildMetaRow('Pajak (Ekskl. 10%)', 'Rp 4.650'),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(51150.0.formatRupiah(), style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text('- - - - - - - - - - - - - - - -', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'monospace', color: AppColors.outlineVariant)),
                      const SizedBox(height: AppSpacing.sm),

                      // Payment
                      _buildMetaRow('Metode', 'CASH'),
                      _buildMetaRow('Bayar', 'Rp 100.000'),
                      _buildMetaRow('Kembali', 'Rp 48.850'),

                      const SizedBox(height: AppSpacing.md),
                      const Text('- - - - - - - - - - - - - - - -', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'monospace', color: AppColors.outlineVariant)),
                      const SizedBox(height: AppSpacing.md),

                      // Footer note
                      if (receiptFooter.trim().isNotEmpty) ...[
                        Text(
                          receiptFooter.trim(),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: AppColors.outline),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      const Text(
                        'Terima kasih telah berbelanja',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.outline),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.onSurfaceVariant)),
          Text(right, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildItemRow(String name, String qtyPrice, String total, {bool isDisc = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDisc ? AppColors.warning : AppColors.onSurface,
            ),
          ),
          if (qtyPrice.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(qtyPrice, style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: AppColors.outline)),
                Text(total, style: const TextStyle(fontFamily: 'monospace', fontSize: 10)),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(total, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.warning)),
              ],
            ),
        ],
      ),
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : AppColors.outlineVariant,
            height: 1,
          ),
        ),
      ),
    );
  }
}
