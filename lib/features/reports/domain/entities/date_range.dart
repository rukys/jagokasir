enum ReportPeriod {
  today,
  yesterday,
  last7Days,
  last30Days,
  thisMonth,
  lastMonth,
  custom,
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  factory DateRange.fromPeriod(ReportPeriod period, {DateTime? customStart, DateTime? customEnd}) {
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.today:
        final start = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateRange(start: start, end: end);
      case ReportPeriod.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        final start = DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0, 0, 0);
        final end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59, 999);
        return DateRange(start: start, end: end);
      case ReportPeriod.last7Days:
        final start = DateTime(now.year, now.month, now.day - 6, 0, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateRange(start: start, end: end);
      case ReportPeriod.last30Days:
        final start = DateTime(now.year, now.month, now.day - 29, 0, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateRange(start: start, end: end);
      case ReportPeriod.thisMonth:
        final start = DateTime(now.year, now.month, 1, 0, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateRange(start: start, end: end);
      case ReportPeriod.lastMonth:
        final firstOfCurrentMonth = DateTime(now.year, now.month, 1);
        final lastDayOfLastMonth = firstOfCurrentMonth.subtract(const Duration(days: 1));
        final start = DateTime(lastDayOfLastMonth.year, lastDayOfLastMonth.month, 1, 0, 0, 0, 0);
        final end = DateTime(lastDayOfLastMonth.year, lastDayOfLastMonth.month, lastDayOfLastMonth.day, 23, 59, 59, 999);
        return DateRange(start: start, end: end);
      case ReportPeriod.custom:
        return DateRange(
          start: customStart ?? DateTime(now.year, now.month, now.day, 0, 0, 0, 0),
          end: customEnd ?? DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
        );
    }
  }
}
