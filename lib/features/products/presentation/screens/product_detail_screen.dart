import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (product) {
          final theme = Theme.of(context);

          return CustomScrollView(
            slivers: [
              // Hero image + AppBar
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProductImageHero(imagePath: product.imagePath),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () => context.push(
                      AppRoutes.productEdit.replaceAll(':id', product.id),
                      extra: product,
                    ),
                    tooltip: 'Edit',
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama + badge status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _StatusBadge(isActive: product.isActive),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // SKU + kategori
                      Text(
                        'SKU: ${product.sku}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (product.categoryName != null)
                        Text(
                          'Kategori: ${product.categoryName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                      const SizedBox(height: AppSpacing.xl),
                      const Divider(),
                      const SizedBox(height: AppSpacing.xl),

                      // Harga
                      _InfoRow(
                        label: 'Harga Jual',
                        value: product.sellingPrice.formatRupiah(),
                        valueStyle: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (product.costPrice != null)
                        _InfoRow(
                          label: 'Harga Modal',
                          value: product.costPrice!.formatRupiah(),
                        ),
                      if (product.costPrice != null)
                        _InfoRow(
                          label: 'Margin',
                          value:
                              (product.sellingPrice - product.costPrice!).formatRupiah(),
                          valueStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.success,
                          ),
                        ),

                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.lg),

                      // Detail info
                      _InfoRow(label: 'Satuan', value: product.unit),
                      if (product.barcode != null)
                        _InfoRow(label: 'Barcode', value: product.barcode!),
                      _InfoRow(
                        label: 'Stok',
                        value: '— (lihat menu Stok)',
                        valueStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      _InfoRow(
                        label: 'Dibuat',
                        value: product.createdAt.toDisplayDateTime(),
                      ),
                      _InfoRow(
                        label: 'Diperbarui',
                        value: product.updatedAt.toDisplayDateTime(),
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      // Action buttons
                      AppButton(
                        label: product.isActive ? 'Nonaktifkan Produk' : 'Aktifkan Produk',
                        variant: AppButtonVariant.outlined,
                        icon: Icon(
                          product.isActive
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: AppSpacing.iconSizeMd,
                        ),
                        onPressed: () => _toggleActive(context, ref, product.id),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton.destructive(
                        label: 'Hapus Produk',
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: AppSpacing.iconSizeMd,
                        ),
                        onPressed: () => _delete(context, ref, product.id),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleActive(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    LoadingOverlay.show(context);
    final success =
        await ref.read(productActionNotifierProvider.notifier).toggleActive(id);
    if (!context.mounted) return;
    LoadingOverlay.hide(context);
    if (success) {
      ErrorSnackbar.showSuccess(context, 'Status produk berhasil diubah');
    } else {
      final msg = ref.read(productActionNotifierProvider.notifier).errorMessage;
      ErrorSnackbar.showError(context, msg ?? 'Gagal mengubah status');
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Hapus Produk?',
      message: 'Produk akan dihapus. Tindakan ini tidak bisa dibatalkan.',
      confirmText: 'Hapus',
      isDestructive: true,
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    LoadingOverlay.show(context);
    final success =
        await ref.read(productActionNotifierProvider.notifier).softDelete(id);
    if (!context.mounted) return;
    LoadingOverlay.hide(context);

    if (success) {
      ErrorSnackbar.showSuccess(context, 'Produk berhasil dihapus');
      context.pop();
    } else {
      final msg = ref.read(productActionNotifierProvider.notifier).errorMessage;
      ErrorSnackbar.showError(context, msg ?? 'Gagal menghapus produk');
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ProductImageHero extends StatelessWidget {
  const _ProductImageHero({required this.imagePath});
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/product_placeholder.png',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }
    return Image.asset(
      'assets/images/product_placeholder.png',
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successLight : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isActive ? AppColors.success : AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueStyle});
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
