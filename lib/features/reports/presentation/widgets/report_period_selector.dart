// lib/features/reports/presentation/widgets/report_period_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/date_range.dart';
import '../providers/report_provider.dart';

class ReportPeriodSelector extends ConsumerWidget {
  const ReportPeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPeriod = ref.watch(selectedReportPeriodProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ReportPeriod.values.map((p) {
          final isSelected = p == currentPeriod;
          String label;
          switch (p) {
            case ReportPeriod.today:
              label = 'Hari Ini';
              break;
            case ReportPeriod.yesterday:
              label = 'Kemarin';
              break;
            case ReportPeriod.last7Days:
              label = '7 Hari';
              break;
            case ReportPeriod.last30Days:
              label = '30 Hari';
              break;
            case ReportPeriod.thisMonth:
              label = 'Bulan Ini';
              break;
            case ReportPeriod.lastMonth:
              label = 'Bulan Lalu';
              break;
            case ReportPeriod.custom:
              label = 'Kustom 📅';
              break;
          }

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) async {
                if (selected) {
                  if (p == ReportPeriod.custom) {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: DateTimeRange(
                        start: DateTime.now().subtract(const Duration(days: 7)),
                        end: DateTime.now(),
                      ),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primary,
                              onPrimary: AppColors.onPrimary,
                              surface: AppColors.surface,
                              onSurface: AppColors.onSurface,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      ref.read(customDateRangeProvider.notifier).state =
                          DateRange(
                        start: DateTime(picked.start.year, picked.start.month,
                            picked.start.day, 0, 0, 0),
                        end: DateTime(picked.end.year, picked.end.month,
                            picked.end.day, 23, 59, 59, 999),
                      );
                      ref.read(selectedReportPeriodProvider.notifier).state = p;
                    }
                  } else {
                    ref.read(selectedReportPeriodProvider.notifier).state = p;
                  }
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
