// lib/features/stock/presentation/screens/stock_overview_screen.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/stock_entity.dart';
import '../providers/stock_provider.dart';

class StockOverviewScreen extends ConsumerStatefulWidget {
  const StockOverviewScreen({super.key});

  @override
  ConsumerState<StockOverviewScreen> createState() =>
      _StockOverviewScreenState();
}

class _StockOverviewScreenState extends ConsumerState<StockOverviewScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  bool _showLowStockOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = value.trim().toLowerCase());
    });
  }

  void _navigateToAdjustment({String? productId, String? productName}) {
    // Reset notifier sebelum navigate agar tidak ada stale state
    ref.read(stockAdjustmentNotifierProvider.notifier).reset();
    context.push(
      AppRoutes.stockAdjustment,
      extra: {'productId': productId, 'productName': productName},
    );
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCountAsync = ref.watch(lowStockCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stok'),
        actions: [
          // Badge low stock
          lowStockCountAsync.maybeWhen(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          tooltip: 'Filter stok rendah',
                          icon: const Icon(Icons.warning_amber_rounded),
                          color: _showLowStockOnly
                              ? AppColors.danger
                              : AppColors.warning,
                          onPressed: () => setState(
                            () => _showLowStockOnly = !_showLowStockOnly,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              count > 99 ? '99+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(stockListProvider);
              ref.invalidate(lowStockListProvider);
              ref.invalidate(lowStockCountProvider);
            },
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
                hintText: 'Cari nama produk atau SKU...',
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

          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _FilterTab(
                  label: 'Semua Stok',
                  isActive: !_showLowStockOnly,
                  onTap: () => setState(() => _showLowStockOnly = false),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterTab(
                  label: 'Stok Rendah',
                  isActive: _showLowStockOnly,
                  badgeColor: AppColors.danger,
                  onTap: () => setState(() => _showLowStockOnly = true),
                ),
              ],
            ),
          ),

          // Stock list
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(stockListProvider);
                ref.invalidate(lowStockListProvider);
                ref.invalidate(lowStockCountProvider);
              },
              child: _showLowStockOnly
                  ? _StockListWidget(
                      asyncStocks: ref.watch(lowStockListProvider),
                      searchQuery: _searchQuery,
                      onAdjust: _navigateToAdjustment,
                      emptyTitle: 'Tidak ada stok rendah',
                      emptySubtitle: 'Semua stok dalam kondisi aman 👍',
                      emptyIcon: Icons.check_circle_outline_rounded,
                    )
                  : _StockListWidget(
                      asyncStocks: ref.watch(stockListProvider),
                      searchQuery: _searchQuery,
                      onAdjust: _navigateToAdjustment,
                      emptyTitle: 'Belum ada produk',
                      emptySubtitle:
                          'Tambah produk terlebih dahulu di menu Produk',
                      emptyIcon: Icons.inventory_2_outlined,
                    ),
            ),
          ),
        ],
      ),
      // FAB: bulat dengan ikon tune, posisi kanan bawah dengan margin yang cukup
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: FloatingActionButton(
          heroTag: 'fab_stock_adjustment',
          onPressed: () => _navigateToAdjustment(),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          tooltip: 'Adjustment Stok',
          elevation: 3,
          child: const Icon(Icons.tune_rounded, size: 26),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeColor,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: badgeColor != null && isActive
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
            )
          : null,
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onTap(),
    );
  }
}

// ── Stock list widget ─────────────────────────────────────────────────────────

class _StockListWidget extends StatelessWidget {
  const _StockListWidget({
    required this.asyncStocks,
    required this.searchQuery,
    required this.onAdjust,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
  });

  final AsyncValue<List<StockEntity>> asyncStocks;
  final String searchQuery;
  final void Function({String? productId, String? productName}) onAdjust;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    return asyncStocks.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
      data: (stocks) {
        final filtered = searchQuery.isEmpty
            ? stocks
            : stocks
                .where(
                  (s) =>
                      s.productName.toLowerCase().contains(searchQuery) ||
                      s.productSku.toLowerCase().contains(searchQuery),
                )
                .toList();

        if (filtered.isEmpty) {
          return EmptyState(
            icon: emptyIcon,
            title: searchQuery.isNotEmpty ? 'Tidak ditemukan' : emptyTitle,
            subtitle: searchQuery.isNotEmpty
                ? 'Coba kata kunci berbeda'
                : emptySubtitle,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) => _StockCard(
            stock: filtered[i],
            onAdjust: () => onAdjust(
              productId: filtered[i].productId,
              productName: filtered[i].productName,
            ),
            onHistory: () => context.push(
              AppRoutes.stockLedger.replaceAll(
                ':productId',
                filtered[i].productId,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Stock card ───────────────────────────────────────────────────────────────

class _StockCard extends StatelessWidget {
  const _StockCard({
    required this.stock,
    required this.onAdjust,
    required this.onHistory,
  });

  final StockEntity stock;
  final VoidCallback onAdjust;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLow = stock.isLowStock;

    // Progress bar: current / minimum (jika minimum > 0)
    final progress = stock.minimumStock > 0
        ? (stock.currentStock / (stock.minimumStock * 2)).clamp(0.0, 1.0)
        : 1.0;

    final stockColor = isLow ? AppColors.danger : AppColors.success;
    final stockBgColor = isLow ? AppColors.dangerLight : AppColors.successLight;

    return GestureDetector(
      onTap: onHistory,
      onLongPress: onAdjust,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isLow ? AppColors.danger.withOpacity(0.4) : AppColors.outlineVariant,
            width: isLow ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: _StockProductImage(
                imagePath: stock.productImagePath,
                size: 56,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama produk + badge low stock
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stock.productName,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLow)
                        Container(
                          margin: const EdgeInsets.only(left: AppSpacing.xs),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.stockLowBg,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            'RENDAH',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.stockLow,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stock.productSku,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Progress bar
                  if (stock.trackStock && stock.minimumStock > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation(stockColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Stok saat ini
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: stockBgColor,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          _formatStock(stock.currentStock),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: stockColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        stock.productUnit,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (stock.trackStock && stock.minimumStock > 0) ...[
                        Text(
                          '  ·  min ${_formatStock(stock.minimumStock)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  color: AppColors.primary,
                  tooltip: 'Adjustment stok',
                  onPressed: onAdjust,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.history_rounded, size: 20),
                  color: AppColors.onSurfaceVariant,
                  tooltip: 'Riwayat stok',
                  onPressed: onHistory,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatStock(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

// ── Product image ─────────────────────────────────────────────────────────────

class _StockProductImage extends StatelessWidget {
  const _StockProductImage({required this.imagePath, required this.size});
  final String? imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.file(
        File(imagePath!),
        height: size,
        width: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Image.asset(
      'assets/images/product_placeholder.png',
      height: size,
      width: size,
      fit: BoxFit.cover,
    );
  }
}
