// lib/features/reports/presentation/screens/category_report_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/category_report_entity.dart';
import '../providers/report_provider.dart';
import '../widgets/report_period_selector.dart';

class CategoryReportScreen extends ConsumerStatefulWidget {
  const CategoryReportScreen({super.key});

  @override
  ConsumerState<CategoryReportScreen> createState() => _CategoryReportScreenState();
}

class _CategoryReportScreenState extends ConsumerState<CategoryReportScreen> {
  int _touchedIndex = -1;

  Color _getCategoryColor(String name, int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      Colors.blue[700]!,
      Colors.indigo[600]!,
      Colors.purple[600]!,
      Colors.orange[700]!,
      Colors.pink[600]!,
      Colors.teal[700]!,
      Colors.cyan[700]!,
    ];
    return colors[index % colors.length];
  }

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
    final theme = Theme.of(context);
    final dateRange = ref.watch(currentReportDateRangeProvider);

    final reportAsync = ref.watch(categoryReportProvider(dateRange));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kontribusi Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
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
              child: reportAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return _buildEmptyState();
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pie Chart Widget
                        _buildPieChartCard(list),
                        const Gap(AppSpacing.lg),

                        // Table breakdown
                        Text(
                          'Rincian Kontribusi Kategori',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        const Gap(AppSpacing.md),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final item = list[index];
                            final color = _getCategoryColor(item.categoryName, index);
                            return _buildCategoryItem(item, color);
                          },
                        ),
                        const Gap(AppSpacing.xxl),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => Center(child: Text('Gagal memuat laporan kategori: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard(List<CategoryReportEntity> list) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Distribusi Omset Penjualan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
          ),
          const Gap(AppSpacing.lg),
          Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _buildPieChartSections(list),
                    ),
                  ),
                ),
              ),
              const Gap(AppSpacing.md),

              // Simple Legends (Top 4)
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    list.length.clamp(0, 5),
                    (index) {
                      final item = list[index];
                      final color = _getCategoryColor(item.categoryName, index);
                      final pctStr = '${(item.percentage * 100).toStringAsFixed(1)}%';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const Gap(AppSpacing.sm),
                            Expanded(
                              child: Text(
                                item.categoryName,
                                style: const TextStyle(fontSize: 11, color: AppColors.onSurface, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Gap(AppSpacing.xs),
                            Text(
                              pctStr,
                              style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(List<CategoryReportEntity> list) {
    return List.generate(list.length, (i) {
      final item = list[i];
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 14.0 : 10.0;
      final radius = isTouched ? 60.0 : 50.0;
      final color = _getCategoryColor(item.categoryName, i);
      final double val = item.percentage * 100;

      return PieChartSectionData(
        color: color,
        value: val,
        title: '${val.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    });
  }

  Widget _buildCategoryItem(CategoryReportEntity item, Color color) {
    final pctStr = '${(item.percentage * 100).toStringAsFixed(1)}%';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface, fontSize: 13),
                ),
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      '${item.transactionCount} Transaksi',
                      style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                    ),
                    const Gap(AppSpacing.md),
                    Text(
                      'Terjual: ${item.totalQuantitySold.toStringAsFixed(0)} item',
                      style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatIdr(item.totalRevenue),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface, fontSize: 13),
              ),
              const Gap(2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  pctStr,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.onPrimaryContainer),
                ),
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
          Icon(Icons.pie_chart_outline_rounded, size: 64, color: AppColors.outlineVariant),
          Gap(AppSpacing.md),
          Text(
            'Tidak ada data kontribusi kategori',
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
