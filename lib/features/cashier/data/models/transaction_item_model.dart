import '../../../../core/constants/db_constants.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../domain/entities/transaction_item_entity.dart';

class TransactionItemModel extends TransactionItemEntity {
  const TransactionItemModel({
    required super.id,
    required super.transactionId,
    required super.productId,
    required super.productName,
    required super.productSku,
    required super.sellingPrice,
    super.costPrice,
    required super.quantity,
    super.itemDiscountType,
    super.itemDiscountValue,
    required super.itemDiscountAmount,
    required super.lineTotal,
  });

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      id: map[DbConstants.colId] as String,
      transactionId: map[DbConstants.colTransactionId] as String,
      productId: map[DbConstants.colProductId] as String,
      productName: map[DbConstants.colProductName] as String,
      productSku: map[DbConstants.colProductSku] as String,
      sellingPrice: (map[DbConstants.colSellingPrice] as num).toDouble(),
      costPrice: map[DbConstants.colCostPrice] != null
          ? (map[DbConstants.colCostPrice] as num).toDouble()
          : null,
      quantity: (map[DbConstants.colQuantity] as num).toDouble(),
      itemDiscountType: map[DbConstants.colItemDiscountType] != null
          ? _stringToDiscountType(map[DbConstants.colItemDiscountType] as String)
          : null,
      itemDiscountValue: map[DbConstants.colItemDiscountValue] != null
          ? (map[DbConstants.colItemDiscountValue] as num).toDouble()
          : null,
      itemDiscountAmount: (map[DbConstants.colItemDiscountAmount] as num).toDouble(),
      lineTotal: (map[DbConstants.colLineTotal] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DbConstants.colId: id,
      DbConstants.colTransactionId: transactionId,
      DbConstants.colProductId: productId,
      DbConstants.colProductName: productName,
      DbConstants.colProductSku: productSku,
      DbConstants.colSellingPrice: sellingPrice,
      DbConstants.colCostPrice: costPrice,
      DbConstants.colQuantity: quantity,
      DbConstants.colItemDiscountType: _discountTypeToString(itemDiscountType),
      DbConstants.colItemDiscountValue: itemDiscountValue,
      DbConstants.colItemDiscountAmount: itemDiscountAmount,
      DbConstants.colLineTotal: lineTotal,
    };
  }

  static DiscountType? _stringToDiscountType(String value) {
    return DiscountType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => DiscountType.percentage,
    );
  }

  static String? _discountTypeToString(DiscountType? type) {
    if (type == null) return null;
    return type.name.toUpperCase();
  }
}
