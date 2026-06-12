// lib/features/reports/presentation/screens/product_performance_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/product_performance_entity.dart';
import '../providers/report_provider.dart';
import '../widgets/report_period_selector.dart';

class ProductPerformanceScreen extends ConsumerStatefulWidget {
  const ProductPerformanceScreen({super.key});

  @override
  ConsumerState<ProductPerformanceScreen> createState() => _ProductPerformanceScreenState();
}

class _ProductPerformanceScreenState extends ConsumerState<ProductPerformanceScreen> {
  bool _sortByQty = true;

  String _formatIdr(double val) {
    final str = val.toStringAsFixed(0);
    final sb = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      sb.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        sb.write('.');
      }
    }
    return 'Rp ${sb.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(currentStaffProvider);
    final dateRange = ref.watch(currentReportDateRangeProvider);
    final isOwner = staff?.role == StaffRole.owner;

    final performanceAsync = ref.watch(
      productPerformanceProvider(dateRange, sortByQty: _sortByQty),
    );

    final exportState = ref.watch(exportReportNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Performa Produk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.onBackground,
        actions: [
          if (exportState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Export CSV',
              onPressed: () async {
                final list = performanceAsync.valueOrNull ?? [];
                if (list.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tidak ada data produk untuk diekspor')),
                  );
                  return;
                }
                final dateStr = DateTime.now().toIso8601String().split('T').first;
                await ref.read(exportReportNotifierProvider.notifier).exportProductsCsv(
                      products: list,
                      fileName: 'performa_produk_$dateStr.csv',
                      isOwner: isOwner,
                    );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.pagePadding,
                right: AppSpacing.pagePadding,
                top: AppSpacing.md,
              ),
              child: const ReportPeriodSelector(),
            ),
            // Sorting Selector Toggle
            _buildSortToggle(),

            // Table header or label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'DAFTAR PRODUK TERLARIS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  Text(
                    _sortByQty ? 'URUT QUANTITY' : 'URUT PENDAPATAN',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.xs),

            // Main performance list
            Expanded(
              child: performanceAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final product = list[index];
                      return _buildProductItem(product, index + 1, isOwner);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => Center(child: Text('Gagal memuat performa produk: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortToggle() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.pagePadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5), width: 0.8),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _sortByQty = true;
                });
              },
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusFull),
                bottomLeft: Radius.circular(AppSpacing.radiusFull),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: _sortByQty ? AppColors.primaryContainer : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusFull),
                    bottomLeft: Radius.circular(AppSpacing.radiusFull),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Paling Banyak Terjual (Qty)',
                    style: TextStyle(
                      fontWeight: _sortByQty ? FontWeight.bold : FontWeight.normal,
                      color: _sortByQty ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _sortByQty = false;
                });
              },
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppSpacing.radiusFull),
                bottomRight: Radius.circular(AppSpacing.radiusFull),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: !_sortByQty ? AppColors.primaryContainer : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(AppSpacing.radiusFull),
                    bottomRight: Radius.circular(AppSpacing.radiusFull),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Pendapatan Terbesar (Rp)',
                    style: TextStyle(
                      fontWeight: !_sortByQty ? FontWeight.bold : FontWeight.normal,
                      color: !_sortByQty ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(ProductPerformanceEntity product, int rank, bool isOwner) {
    // Determine margin details
    double marginPercent = 0.0;
    if (product.grossProfit != null && product.totalRevenue > 0) {
      marginPercent = (product.grossProfit! / product.totalRevenue) * 100;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank Circle badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppColors.primary : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.md),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(AppSpacing.xs),
                Text(
                  'SKU: ${product.productSku}',
                  style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                ),
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 12, color: AppColors.onSurfaceVariant),
                    const Gap(AppSpacing.xs),
                    Text(
                      'Terjual: ${product.totalQuantitySold.toStringAsFixed(0)} pcs',
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                if (isOwner) ...[
                  const Divider(height: 12, thickness: 0.5),
                  // Profit metrics (Owner only)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('HPP (Modal)', style: TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant)),
                          Text(
                            product.totalCostPrice != null ? _formatIdr(product.totalCostPrice!) : '-',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Laba Kotor', style: TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant)),
                          Text(
                            product.grossProfit != null ? _formatIdr(product.grossProfit!) : '-',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: product.grossProfit != null && product.grossProfit! >= 0
                                  ? AppColors.primary
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Margin %', style: TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant)),
                          Text(
                            product.grossProfit != null ? '${marginPercent.toStringAsFixed(1)}%' : '-',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Gap(AppSpacing.md),

          // Total Revenue Trailing
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('PENDAPATAN', style: TextStyle(fontSize: 8, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
              const Gap(2),
              Text(
                _formatIdr(product.totalRevenue),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.outlineVariant),
          Gap(AppSpacing.md),
          Text(
            'Tidak ada data performa produk',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
          ),
          Gap(AppSpacing.xs),
          Text(
            'Belum ada transaksi selesai di periode ini.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
