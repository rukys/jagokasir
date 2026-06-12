class DailySalesEntity {
  final DateTime date;
  final double revenue;
  final int transactionCount;

  const DailySalesEntity({
    required this.date,
    required this.revenue,
    required this.transactionCount,
  });
}
