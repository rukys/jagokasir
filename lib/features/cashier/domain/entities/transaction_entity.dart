import '../../../../core/utils/price_calculator.dart';
import 'transaction_item_entity.dart';

enum PaymentMethod {
  cash,
  transfer,
  qris,
  debit,
  credit;

  String toDbValue() => name.toUpperCase();

  static PaymentMethod fromDbValue(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PaymentMethod.cash,
    );
  }
}

enum TransactionStatus {
  completed,
  voided;

  String toDbValue() => name.toUpperCase();

  static TransactionStatus fromDbValue(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => TransactionStatus.completed,
    );
  }
}

class TransactionEntity {
  final String id;
  final String invoiceNumber;
  final String? staffId;
  final String? staffName; // joined from staffs table
  final double subtotal;
  final DiscountType? discountType;
  final double? discountValue;
  final double discountAmount;
  final double taxRate;
  final bool taxIsInclusive;
  final double taxAmount;
  final double total;
  final PaymentMethod paymentMethod;
  final double? paymentReceived;
  final double? changeAmount;
  final TransactionStatus status;
  final String? voidReason;
  final String? note;
  final DateTime createdAt;
  final List<TransactionItemEntity> items;

  const TransactionEntity({
    required this.id,
    required this.invoiceNumber,
    this.staffId,
    this.staffName,
    required this.subtotal,
    this.discountType,
    this.discountValue,
    required this.discountAmount,
    required this.taxRate,
    required this.taxIsInclusive,
    required this.taxAmount,
    required this.total,
    required this.paymentMethod,
    this.paymentReceived,
    this.changeAmount,
    required this.status,
    this.voidReason,
    this.note,
    required this.createdAt,
    required this.items,
  });

  TransactionEntity copyWith({
    String? id,
    String? invoiceNumber,
    String? staffId,
    String? staffName,
    double? subtotal,
    DiscountType? discountType,
    double? discountValue,
    double? discountAmount,
    double? taxRate,
    bool? taxIsInclusive,
    double? taxAmount,
    double? total,
    PaymentMethod? paymentMethod,
    double? paymentReceived,
    double? changeAmount,
    TransactionStatus? status,
    String? voidReason,
    String? note,
    DateTime? createdAt,
    List<TransactionItemEntity>? items,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      subtotal: subtotal ?? this.subtotal,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      discountAmount: discountAmount ?? this.discountAmount,
      taxRate: taxRate ?? this.taxRate,
      taxIsInclusive: taxIsInclusive ?? this.taxIsInclusive,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReceived: paymentReceived ?? this.paymentReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      status: status ?? this.status,
      voidReason: voidReason ?? this.voidReason,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
