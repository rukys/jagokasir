import '../../../../core/utils/price_calculator.dart';

class TransactionItemEntity {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final String productSku;
  final double sellingPrice;
  final double? costPrice;
  final double quantity;
  final DiscountType? itemDiscountType;
  final double? itemDiscountValue;
  final double itemDiscountAmount;
  final double lineTotal;

  const TransactionItemEntity({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.sellingPrice,
    this.costPrice,
    required this.quantity,
    this.itemDiscountType,
    this.itemDiscountValue,
    required this.itemDiscountAmount,
    required this.lineTotal,
  });
}
