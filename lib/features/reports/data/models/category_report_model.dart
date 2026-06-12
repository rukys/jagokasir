import '../../domain/entities/category_report_entity.dart';

class CategoryReportModel extends CategoryReportEntity {
  const CategoryReportModel({
    required super.categoryName,
    required super.transactionCount,
    required super.totalQuantitySold,
    required super.totalRevenue,
    required super.percentage,
  });

  factory CategoryReportModel.fromMap(Map<String, dynamic> map, double totalRevenueSum) {
    final revenue = (map['total_revenue'] as num?)?.toDouble() ?? 0.0;
    final pct = totalRevenueSum > 0 ? (revenue / totalRevenueSum) : 0.0;

    return CategoryReportModel(
      categoryName: map['category_name'] as String? ?? 'Uncategorized',
      transactionCount: (map['transaction_count'] as num?)?.toInt() ?? 0,
      totalQuantitySold: (map['total_qty'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: revenue,
      percentage: pct,
    );
  }
}
