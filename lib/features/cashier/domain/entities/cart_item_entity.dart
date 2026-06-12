import '../../../../core/utils/price_calculator.dart';

class CartItemEntity {
  final String productId;
  final String productName;
  final String productSku;
  final double sellingPrice;
  final double? costPrice;
  final String unit;
  final bool trackStock;
  final double currentStock;
  final double quantity;
  final DiscountType? discountType;
  final double? discountValue;

  const CartItemEntity({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.sellingPrice,
    this.costPrice,
    required this.unit,
    required this.trackStock,
    required this.currentStock,
    required this.quantity,
    this.discountType,
    this.discountValue,
  });

  /// Kalkulasi nominal diskon per item
  double get itemDiscountAmount {
    return PriceCalculator.calculateItemDiscountAmount(
      price: sellingPrice,
      quantity: quantity,
      type: discountType,
      value: discountValue,
    );
  }

  /// Kalkulasi total harga setelah diskon item
  double get lineTotal {
    return PriceCalculator.calculateLineTotal(
      price: sellingPrice,
      quantity: quantity,
      discountAmount: itemDiscountAmount,
    );
  }

  CartItemEntity copyWith({
    String? productId,
    String? productName,
    String? productSku,
    double? sellingPrice,
    double? costPrice,
    String? unit,
    bool? trackStock,
    double? currentStock,
    double? quantity,
    DiscountType? discountType,
    double? discountValue,
    bool clearDiscount = false,
  }) {
    return CartItemEntity(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      unit: unit ?? this.unit,
      trackStock: trackStock ?? this.trackStock,
      currentStock: currentStock ?? this.currentStock,
      quantity: quantity ?? this.quantity,
      discountType: clearDiscount ? null : (discountType ?? this.discountType),
      discountValue: clearDiscount ? null : (discountValue ?? this.discountValue),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartItemEntity &&
          other.productId == productId &&
          other.quantity == quantity &&
          other.discountType == discountType &&
          other.discountValue == discountValue);

  @override
  int get hashCode =>
      productId.hashCode ^
      quantity.hashCode ^
      discountType.hashCode ^
      discountValue.hashCode;
}
