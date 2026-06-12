import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/currency_display.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart' show ImportResult;
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = value.trim());
    });
  }

  Future<void> _exportCsv() async {
    LoadingOverlay.show(context, message: 'Mengekspor produk...');
    final result = await ref.read(exportProductsCsvUsecaseProvider).call();
    if (!mounted) return;
    LoadingOverlay.hide(context);

    result.fold(
      (f) => ErrorSnackbar.showError(context, f.message),
      (csv) async {
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/produk_export.csv');
        await file.writeAsString(csv);
        await Share.shareXFiles([XFile(file.path)], subject: 'Export Produk JagoKasir');
      },
    );
  }

  Future<void> _importCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.single.path == null) return;

    final content = await File(result.files.single.path!).readAsString();
    if (!mounted) return;

    LoadingOverlay.show(context, message: 'Mengimpor produk...');
    final importResult = await ref
        .read(importCsvNotifierProvider.notifier)
        .importFromString(content);
    if (!mounted) return;
    LoadingOverlay.hide(context);

    if (importResult != null) {
      _showImportResult(importResult);
    } else {
      final errMsg = ref.read(importCsvNotifierProvider.notifier).errorMessage;
      ErrorSnackbar.showError(context, errMsg ?? 'Import gagal');
    }
  }

  void _showImportResult(ImportResult result) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hasil Import'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _resultRow('Berhasil', result.success, AppColors.success),
            _resultRow('Dilewati', result.skipped, AppColors.warning),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Detail error:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 120,
                child: SingleChildScrollView(
                  child: Text(
                    result.errors.join('\n'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
          Text(
            '$value produk',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            tooltip: 'Kategori',
            onPressed: () => context.push(AppRoutes.categories),
            icon: const Icon(Icons.category_outlined),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'import') _importCsv();
              if (value == 'export') _exportCsv();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload_file_outlined, size: AppSpacing.iconSizeMd),
                    SizedBox(width: AppSpacing.sm),
                    Text('Import CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined, size: AppSpacing.iconSizeMd),
                    SizedBox(width: AppSpacing.sm),
                    Text('Export CSV'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.md,
              AppSpacing.pagePadding,
              0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari nama, SKU, atau barcode...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter chips + view toggle
          _CategoryFilterChips(
            selectedId: _selectedCategoryId,
            onSelected: (id) => setState(() => _selectedCategoryId = id),
            isGridView: _isGridView,
            onToggleView: () => setState(() => _isGridView = !_isGridView),
          ),

          // Product list/grid
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(productListProvider);
                ref.invalidate(filteredProductsProvider);
              },
              child: ref
                  .watch(
                    filteredProductsProvider(
                      searchQuery: _searchQuery,
                      categoryId: _selectedCategoryId,
                    ),
                  )
                  .when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                          const SizedBox(height: AppSpacing.sm),
                          Text(e.toString(), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    data: (products) {
                      if (products.isEmpty) {
                        return EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: _searchQuery.isNotEmpty
                              ? 'Produk tidak ditemukan'
                              : 'Belum ada produk',
                          subtitle: _searchQuery.isNotEmpty
                              ? 'Coba kata kunci berbeda'
                              : 'Tap tombol + untuk menambah produk pertama',
                          actionLabel: _searchQuery.isEmpty ? 'Tambah Produk' : null,
                          onAction: _searchQuery.isEmpty
                              ? () => context.push(AppRoutes.productAdd)
                              : null,
                        );
                      }
                      return _isGridView
                          ? _ProductGridView(products: products, theme: theme)
                          : _ProductListView(products: products, theme: theme);
                    },
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_add_product',
        onPressed: () => context.push(AppRoutes.productAdd),
        tooltip: 'Tambah Produk',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ── Category filter chips ────────────────────────────────────────────────────

class _CategoryFilterChips extends ConsumerWidget {
  const _CategoryFilterChips({
    required this.selectedId,
    required this.onSelected,
    required this.isGridView,
    required this.onToggleView,
  });

  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final bool isGridView;
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isSelected: selectedId == null,
                    onTap: () => onSelected(null),
                  ),
                  ...categoriesAsync.maybeWhen(
                    data: (cats) => cats.map(
                      (c) => _FilterChip(
                        label: c.name,
                        isSelected: selectedId == c.id,
                        colorHex: c.colorHex,
                        onTap: () => onSelected(
                          selectedId == c.id ? null : c.id,
                        ),
                      ),
                    ),
                    orElse: () => [],
                  ),
                ],
              ),
            ),
          ),
          // View toggle
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: IconButton(
              onPressed: onToggleView,
              icon: Icon(
                isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
                color: AppColors.onSurfaceVariant,
              ),
              tooltip: isGridView ? 'Tampilan list' : 'Tampilan grid',
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.colorHex,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? colorHex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

// ── Grid view ────────────────────────────────────────────────────────────────

class _ProductGridView extends StatelessWidget {
  const _ProductGridView({required this.products, required this.theme});
  final List<ProductEntity> products;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductGridCard(product: products[i]),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.productDetail.replaceAll(':id', product.id),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusMd),
              ),
              child: _ProductImage(
                imagePath: product.imagePath,
                height: 110,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    product.sku,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  CurrencyDisplay(
                    amount: product.sellingPrice,
                    style: CurrencyDisplayStyle.normal,
                  ),
                  if (!product.isActive) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        'Nonaktif',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── List view ────────────────────────────────────────────────────────────────

class _ProductListView extends StatelessWidget {
  const _ProductListView({required this.products, required this.theme});
  final List<ProductEntity> products;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _ProductListTile(product: products[i]),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.productDetail.replaceAll(':id', product.id),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: _ProductImage(
                imagePath: product.imagePath,
                height: 56,
                width: 56,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.sku,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (product.categoryName != null)
                    Text(
                      product.categoryName!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CurrencyDisplay(
                  amount: product.sellingPrice,
                  style: CurrencyDisplayStyle.small,
                ),
                if (!product.isActive)
                  Text(
                    'Nonaktif',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Product image widget ─────────────────────────────────────────────────────

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imagePath,
    required this.height,
    required this.width,
  });

  final String? imagePath;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.file(
        File(imagePath!),
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(height, width),
      );
    }
    return _placeholder(height, width);
  }

  Widget _placeholder(double h, double w) {
    return Image.asset(
      'assets/images/product_placeholder.png',
      height: h,
      width: w,
      fit: BoxFit.cover,
    );
  }
}
