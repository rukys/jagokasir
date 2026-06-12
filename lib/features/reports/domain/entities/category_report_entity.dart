class CategoryReportEntity {
  final String categoryName;
  final int transactionCount;
  final double totalQuantitySold;
  final double totalRevenue;
  final double percentage;

  const CategoryReportEntity({
    required this.categoryName,
    required this.transactionCount,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.percentage,
  });
}
