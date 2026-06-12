class ProductPerformanceEntity {
  final String productId;
  final String productName;
  final String productSku;
  final double totalQuantitySold;
  final double totalRevenue;
  final double? totalCostPrice;
  final double? grossProfit;

  const ProductPerformanceEntity({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.totalQuantitySold,
    required this.totalRevenue,
    this.totalCostPrice,
    this.grossProfit,
  });
}
