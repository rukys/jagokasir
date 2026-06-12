// lib/features/reports/presentation/screens/profit_report_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/product_performance_entity.dart';
import '../providers/report_provider.dart';
import '../widgets/report_period_selector.dart';

class ProfitReportScreen extends ConsumerStatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  ConsumerState<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends ConsumerState<ProfitReportScreen> {
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
    final isOwner = staff?.role == StaffRole.owner;

    if (!isOwner) {
      return _buildAccessDeniedScreen();
    }

    final theme = Theme.of(context);
    final dateRange = ref.watch(currentReportDateRangeProvider);
    final profitAsync = ref.watch(profitReportProvider(dateRange));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan Laba Kotor', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.onBackground,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.pagePadding,
                right: AppSpacing.pagePadding,
                top: AppSpacing.md,
              ),
              child: const ReportPeriodSelector(),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: profitAsync.when(
                data: (list) {
                  // Calculate totals
                  double totalRevenue = 0;
                  double totalCost = 0;
                  bool hasNullCost = false;

                  for (final p in list) {
                    totalRevenue += p.totalRevenue;
                    if (p.totalCostPrice != null) {
                      totalCost += p.totalCostPrice!;
                    } else {
                      hasNullCost = true;
                    }
                  }

                  final grossProfit = totalRevenue - totalCost;
                  final marginPercent = totalRevenue > 0 ? (grossProfit / totalRevenue) * 100 : 0.0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary cards
                        _buildSummaryCards(totalRevenue, totalCost, grossProfit, marginPercent, hasNullCost),
                        const Gap(AppSpacing.lg),

                        // Header title
                        Text(
                          'Performa Profit per Produk',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        if (hasNullCost) ...[
                          const Gap(AppSpacing.xs),
                          const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 12, color: AppColors.onSurfaceVariant),
                              Gap(AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  'Catatan: Produk tanpa HPP ditandai dengan (-) dan tidak dihitung dalam total HPP/Laba.',
                                  style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Gap(AppSpacing.md),

                        // List breakdown
                        if (list.isEmpty)
                          _buildEmptyState()
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final product = list[index];
                              return _buildProfitItem(product);
                            },
                          ),
                        const Gap(AppSpacing.xxl),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => Center(child: Text('Gagal memuat laporan laba: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    double totalRevenue,
    double totalCost,
    double grossProfit,
    double marginPercent,
    bool hasNullCost,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Revenue & COGS
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pendapatan', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    const Gap(AppSpacing.xs),
                    Text(
                      _formatIdr(totalRevenue),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.outlineVariant.withOpacity(0.5)),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Total HPP (Modal)', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        if (hasNullCost) ...[
                          const Gap(2),
                          const Icon(Icons.help_outline_rounded, size: 12, color: AppColors.warning),
                        ],
                      ],
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      _formatIdr(totalCost),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.lg),
          const Divider(height: 1, thickness: 0.8),
          const Gap(AppSpacing.lg),

          // Row 2: Gross Profit & Margin %
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Laba Kotor', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    const Gap(AppSpacing.xs),
                    Text(
                      _formatIdr(grossProfit),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: grossProfit >= 0 ? AppColors.primary : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.outlineVariant.withOpacity(0.5)),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Margin Profitabilitas', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    const Gap(AppSpacing.xs),
                    Text(
                      '${marginPercent.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitItem(ProductPerformanceEntity product) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(AppSpacing.md),
              Text(
                'Qty: ${product.totalQuantitySold.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const Gap(AppSpacing.xs),
          Text(
            'SKU: ${product.productSku}',
            style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
          ),
          const Gap(AppSpacing.sm),
          const Divider(height: 1, thickness: 0.5),
          const Gap(AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProfitColumn('PENDAPATAN', _formatIdr(product.totalRevenue)),
              _buildProfitColumn(
                'HPP (MODAL)',
                product.totalCostPrice != null ? _formatIdr(product.totalCostPrice!) : '-',
              ),
              _buildProfitColumn(
                'LABA KOTOR',
                product.grossProfit != null ? _formatIdr(product.grossProfit!) : '-',
                textColor: product.grossProfit != null && product.grossProfit! >= 0
                    ? AppColors.primary
                    : AppColors.error,
              ),
              _buildProfitColumn(
                'MARGIN %',
                product.grossProfit != null ? '${marginPercent.toStringAsFixed(1)}%' : '-',
                textColor: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitColumn(String label, String value, {Color? textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
        const Gap(2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textColor ?? AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAccessDeniedScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: const BoxDecoration(
                    color: AppColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                ),
                const Gap(AppSpacing.xl),
                const Text(
                  'Akses Terbatas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const Gap(AppSpacing.sm),
                const Text(
                  'Hanya staf dengan role Owner yang diizinkan untuk melihat laporan laba kotor & performa profitabilitas finansial bisnis.',
                  style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const Gap(AppSpacing.xxl),
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    child: const Text('Kembali'),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          Icon(Icons.analytics_outlined, size: 64, color: AppColors.outlineVariant),
          Gap(AppSpacing.md),
          Text(
            'Tidak ada data laba',
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
