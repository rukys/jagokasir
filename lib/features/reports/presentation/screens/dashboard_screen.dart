// lib/features/reports/presentation/screens/dashboard_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../domain/entities/daily_sales_entity.dart';
import '../../domain/entities/date_range.dart';
import '../../domain/entities/sales_summary_entity.dart';
import '../providers/report_provider.dart';
import '../widgets/report_period_selector.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Sore';
    } else {
      return 'Malam';
    }
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

  String _getPeriodLabel(ReportPeriod period, DateRange range) {
    switch (period) {
      case ReportPeriod.today:
        return 'Hari Ini';
      case ReportPeriod.yesterday:
        return 'Kemarin';
      case ReportPeriod.last7Days:
        return '7 Hari Terakhir';
      case ReportPeriod.last30Days:
        return '30 Hari Terakhir';
      case ReportPeriod.thisMonth:
        return 'Bulan Ini';
      case ReportPeriod.lastMonth:
        return 'Bulan Lalu';
      case ReportPeriod.custom:
        final startStr =
            '${range.start.day}/${range.start.month}/${range.start.year}';
        final endStr = '${range.end.day}/${range.end.month}/${range.end.year}';
        return '$startStr - $endStr';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final staff = ref.watch(currentStaffProvider);
    final period = ref.watch(selectedReportPeriodProvider);
    final dateRange = ref.watch(currentReportDateRangeProvider);

    final summaryAsync = ref.watch(salesSummaryProvider(dateRange));
    final trendAsync = ref.watch(dailyTrendProvider(dateRange));
    final lowStockAsync = ref.watch(lowStockCountProvider);
    final storeNameAsync = ref.watch(storeNameProvider);

    final isOwner = staff?.role == StaffRole.owner;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.onBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Bagikan Ringkasan PDF',
            onPressed: () async {
              final summary = summaryAsync.valueOrNull;
              final trend = trendAsync.valueOrNull;
              final storeName = storeNameAsync.valueOrNull ?? 'Toko Saya';

              if (summary == null || trend == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Tunggu data selesai dimuat sebelum ekspor PDF')),
                );
                return;
              }

              final periodLabel = _getPeriodLabel(period, dateRange);
              final dateStr = DateTime.now().toIso8601String().split('T').first;

              await ref
                  .read(exportReportNotifierProvider.notifier)
                  .exportSalesSummaryPdf(
                    storeName: storeName,
                    summary: summary,
                    trend: trend,
                    periodLabel: periodLabel,
                    fileName: 'ringkasan_penjualan_$dateStr.pdf',
                  );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(salesSummaryProvider(dateRange));
            ref.invalidate(dailyTrendProvider(dateRange));
            ref.invalidate(lowStockCountProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding, vertical: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Banner
                  _buildWelcomeBanner(theme, staff),
                  const Gap(AppSpacing.md),

                  // Low Stock Alert Banner
                  lowStockAsync.maybeWhen(
                    data: (count) => count > 0
                        ? _buildLowStockAlert(context, count)
                        : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  if (lowStockAsync.valueOrNull != null &&
                      lowStockAsync.valueOrNull! > 0)
                    const Gap(AppSpacing.md),

                  // Period Selector Chips
                  const ReportPeriodSelector(),
                  const Gap(AppSpacing.lg),

                  // Metrics 2x2 Grid Card
                  summaryAsync.when(
                    data: (summary) => _buildMetricsGrid(summary),
                    loading: () => _buildMetricsShimmer(),
                    error: (err, _) => _buildErrorCard(err.toString()),
                  ),
                  const Gap(AppSpacing.lg),

                  // Interactive LineChart
                  trendAsync.when(
                    data: (trend) => _buildTrendChart(theme, trend),
                    loading: () => _buildChartShimmer(),
                    error: (err, _) => _buildErrorCard(err.toString()),
                  ),
                  const Gap(AppSpacing.lg),

                  // Quick Action Menu Laporan
                  _buildLaporanMenu(context, isOwner),
                  const Gap(AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(ThemeData theme, StaffEntity? staff) {
    final name = staff?.name ?? 'Staf';
    final greeting = _getGreeting();
    IconData greetingIcon;
    switch (greeting) {
      case 'Pagi':
        greetingIcon = Icons.light_mode_outlined;
        break;
      case 'Siang':
        greetingIcon = Icons.wb_sunny_rounded;
        break;
      case 'Sore':
        greetingIcon = Icons.wb_twilight_rounded;
        break;
      default:
        greetingIcon = Icons.nightlight_round;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withBlue(80).withGreen(120),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSpacing.avatarSizeLg / 2,
            backgroundColor: AppColors.onPrimary.withOpacity(0.2),
            child: Icon(greetingIcon,
                color: AppColors.onPrimary, size: AppSpacing.iconSizeLg),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat $greeting,',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.8),
                  ),
                ),
                Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withOpacity(0.3),
        border: Border.all(color: AppColors.warning, width: 0.8),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const Gap(AppSpacing.md),
          Expanded(
            child: Text(
              'Ada $count produk dengan stok kritis!',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.stockList),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('LIHAT STOK',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(SalesSummaryEntity summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      children: [
        _buildMetricCard(
          title: 'Pendapatan',
          value: _formatIdr(summary.totalRevenue),
          icon: Icons.monetization_on_rounded,
          color: AppColors.primary,
        ),
        _buildMetricCard(
          title: 'Transaksi',
          value: '${summary.totalTransactions}',
          icon: Icons.shopping_basket_rounded,
          color: AppColors.secondary,
        ),
        _buildMetricCard(
          title: 'Produk Terjual',
          value: '${summary.totalItemsSold.toStringAsFixed(0)} pcs',
          icon: Icons.local_shipping_rounded,
          color: AppColors.tertiary,
        ),
        _buildMetricCard(
          title: 'Rata-rata Transaksi',
          value: _formatIdr(summary.averageTransactionValue),
          icon: Icons.payments_rounded,
          color: Colors.blueGrey,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.5), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppSpacing.iconSizeMd),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsShimmer() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      children: List.generate(4, (index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTrendChart(ThemeData theme, List<DailySalesEntity> trend) {
    if (trend.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.5), width: 0.8),
        ),
        child: const Center(
          child: Text('Belum ada data transaksi di periode ini',
              style: TextStyle(color: AppColors.onSurfaceVariant)),
        ),
      );
    }

    final double maxRevenue =
        trend.map((e) => e.revenue).fold(0.0, (m, e) => e > m ? e : m);
    final double maxY = maxRevenue == 0 ? 10000 : maxRevenue * 1.25;

    final spots = <FlSpot>[];
    for (int i = 0; i < trend.length; i++) {
      spots.add(FlSpot(i.toDouble(), trend[i].revenue));
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.5), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tren Pendapatan Harian',
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
          const Gap(AppSpacing.lg),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.outlineVariant.withOpacity(0.4),
                    strokeWidth: 0.8,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (trend.length / 5).clamp(1, 100).toDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= trend.length)
                          return const SizedBox.shrink();
                        final date = trend[index].date;
                        return Text(
                          '${date.day}/${date.month}',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.onSurfaceVariant),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (value, meta) {
                        if (value == maxY || value == 0)
                          return const SizedBox.shrink();
                        String formatted;
                        if (value >= 1000000) {
                          formatted =
                              '${(value / 1000000).toStringAsFixed(1)}M';
                        } else if (value >= 1000) {
                          formatted = '${(value / 1000).toStringAsFixed(0)}K';
                        } else {
                          formatted = value.toStringAsFixed(0);
                        }
                        return Text(
                          formatted,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.onSurfaceVariant),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (trend.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: spots.length < 15,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.onPrimary,
                        strokeWidth: 2,
                        strokeColor: AppColors.primary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.25),
                          AppColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => AppColors.secondaryContainer,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = trend[spot.x.toInt()].date;
                        final formattedDate =
                            '${date.day}/${date.month}/${date.year}';
                        final formattedVal = _formatIdr(spot.y);
                        return LineTooltipItem(
                          '$formattedDate\n$formattedVal',
                          const TextStyle(
                            color: AppColors.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartShimmer() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildLaporanMenu(BuildContext context, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Laporan Penjualan',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface),
        ),
        const Gap(AppSpacing.md),
        _buildMenuItem(
          context: context,
          icon: Icons.history_edu_rounded,
          color: AppColors.primary,
          title: 'Laporan Riwayat Transaksi',
          subtitle:
              'Lihat daftar transaksi, filter berdasarkan staff & status.',
          onTap: () => context.push(AppRoutes.reportSales),
        ),
        const Gap(AppSpacing.sm),
        _buildMenuItem(
          context: context,
          icon: Icons.star_outline_rounded,
          color: Colors.amber[800]!,
          title: 'Performa Produk Terlaris',
          subtitle: 'Analisis produk terpopuler berdasarkan qty & pendapatan.',
          onTap: () => context.push('/reports/products'),
        ),
        const Gap(AppSpacing.sm),
        _buildMenuItem(
          context: context,
          icon: Icons.pie_chart_outline_rounded,
          color: AppColors.secondary,
          title: 'Distribusi Kategori Produk',
          subtitle: 'Visualisasi kontribusi omset per kategori produk.',
          onTap: () => context.push('/reports/categories'),
        ),
        const Gap(AppSpacing.sm),
        _buildMenuItem(
          context: context,
          icon: Icons.analytics_outlined,
          color: AppColors.tertiary,
          title: 'Laporan Laba & Margin Kotor',
          subtitle: 'Review modal (HPP), profit kotor, dan persentase margin.',
          isLocked: !isOwner,
          onTap: () {
            if (isOwner) {
              context.push(AppRoutes.reportProfit);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Akses ditolak. Menu ini hanya dapat diakses oleh Owner.')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.5), width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color, size: AppSpacing.iconSizeMd),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface),
                      ),
                      if (isLocked) ...[
                        const Gap(AppSpacing.xs),
                        const Icon(Icons.lock_rounded,
                            size: 14, color: AppColors.warning),
                      ],
                    ],
                  ),
                  const Gap(AppSpacing.xs),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.error),
      ),
      child: Text(
        'Gagal memuat data: $error',
        style: const TextStyle(color: AppColors.onErrorContainer),
      ),
    );
  }
}
