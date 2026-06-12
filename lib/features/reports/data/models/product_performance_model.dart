import '../../domain/entities/product_performance_entity.dart';

class ProductPerformanceModel extends ProductPerformanceEntity {
  const ProductPerformanceModel({
    required super.productId,
    required super.productName,
    required super.productSku,
    required super.totalQuantitySold,
    required super.totalRevenue,
    super.totalCostPrice,
    super.grossProfit,
  });

  factory ProductPerformanceModel.fromMap(Map<String, dynamic> map) {
    final qty = (map['total_qty'] as num?)?.toDouble() ?? 0.0;
    final revenue = (map['total_revenue'] as num?)?.toDouble() ?? 0.0;
    
    // cost_price can be null if cost price was not specified.
    // In our SQLite query we will sum `quantity * cost_price`.
    // Let's check if the raw query field `total_cost` exists.
    final totalCost = map['total_cost'] != null ? (map['total_cost'] as num).toDouble() : null;

    double? grossProfit;
    if (totalCost != null) {
      grossProfit = revenue - totalCost;
    }

    return ProductPerformanceModel(
      productId: map['product_id'] as String? ?? '',
      productName: map['product_name'] as String? ?? '',
      productSku: map['product_sku'] as String? ?? '',
      totalQuantitySold: qty,
      totalRevenue: revenue,
      totalCostPrice: totalCost,
      grossProfit: grossProfit,
    );
  }
}
