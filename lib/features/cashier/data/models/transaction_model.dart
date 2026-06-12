import '../../../../core/constants/db_constants.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_item_model.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.invoiceNumber,
    super.staffId,
    super.staffName,
    required super.subtotal,
    super.discountType,
    super.discountValue,
    required super.discountAmount,
    required super.taxRate,
    required super.taxIsInclusive,
    required super.taxAmount,
    required super.total,
    required super.paymentMethod,
    super.paymentReceived,
    super.changeAmount,
    required super.status,
    super.voidReason,
    super.note,
    required super.createdAt,
    required super.items,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, List<TransactionItemModel> items) {
    return TransactionModel(
      id: map[DbConstants.colId] as String,
      invoiceNumber: map[DbConstants.colInvoiceNumber] as String,
      staffId: map[DbConstants.colStaffId] as String?,
      staffName: map['staff_name'] as String?, // joined dari staffs
      subtotal: (map[DbConstants.colSubtotal] as num).toDouble(),
      discountType: map[DbConstants.colDiscountType] != null
          ? _stringToDiscountType(map[DbConstants.colDiscountType] as String)
          : null,
      discountValue: map[DbConstants.colDiscountValue] != null
          ? (map[DbConstants.colDiscountValue] as num).toDouble()
          : null,
      discountAmount: (map[DbConstants.colDiscountAmount] as num).toDouble(),
      taxRate: (map[DbConstants.colTaxRate] as num).toDouble(),
      taxIsInclusive: (map[DbConstants.colTaxIsInclusive] as int) == 1,
      taxAmount: (map[DbConstants.colTaxAmount] as num).toDouble(),
      total: (map[DbConstants.colTotal] as num).toDouble(),
      paymentMethod: PaymentMethod.fromDbValue(map[DbConstants.colPaymentMethod] as String),
      paymentReceived: map[DbConstants.colPaymentReceived] != null
          ? (map[DbConstants.colPaymentReceived] as num).toDouble()
          : null,
      changeAmount: map[DbConstants.colChangeAmt] != null
          ? (map[DbConstants.colChangeAmt] as num).toDouble()
          : null,
      status: TransactionStatus.fromDbValue(map[DbConstants.colStatus] as String),
      voidReason: map[DbConstants.colVoidReason] as String?,
      note: map[DbConstants.colNote] as String?,
      createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DbConstants.colId: id,
      DbConstants.colInvoiceNumber: invoiceNumber,
      DbConstants.colStaffId: staffId,
      DbConstants.colSubtotal: subtotal,
      DbConstants.colDiscountType: _discountTypeToString(discountType),
      DbConstants.colDiscountValue: discountValue,
      DbConstants.colDiscountAmount: discountAmount,
      DbConstants.colTaxRate: taxRate,
      DbConstants.colTaxIsInclusive: taxIsInclusive ? 1 : 0,
      DbConstants.colTaxAmount: taxAmount,
      DbConstants.colTotal: total,
      DbConstants.colPaymentMethod: paymentMethod.toDbValue(),
      DbConstants.colPaymentReceived: paymentReceived,
      DbConstants.colChangeAmt: changeAmount,
      DbConstants.colStatus: status.toDbValue(),
      DbConstants.colVoidReason: voidReason,
      DbConstants.colNote: note,
      DbConstants.colCreatedAt: createdAt.toIso8601String(),
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
