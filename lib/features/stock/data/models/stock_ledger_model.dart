// lib/features/stock/data/models/stock_ledger_model.dart

import '../../domain/entities/stock_ledger_entity.dart';

/// Model ledger stok — extends [StockLedgerEntity], tambah fromMap.
/// `staffName` diisi dari hasil JOIN query dengan tabel `staffs`.
class StockLedgerModel extends StockLedgerEntity {
  const StockLedgerModel({
    required super.id,
    required super.productId,
    required super.changeAmount,
    required super.stockAfter,
    required super.reason,
    super.referenceId,
    super.note,
    super.staffId,
    super.staffName,
    required super.createdAt,
  });

  factory StockLedgerModel.fromMap(Map<String, dynamic> map) {
    return StockLedgerModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      changeAmount: (map['change_amount'] as num).toDouble(),
      stockAfter: (map['stock_after'] as num).toDouble(),
      reason: map['reason'] as String,
      referenceId: map['reference_id'] as String?,
      note: map['note'] as String?,
      staffId: map['staff_id'] as String?,
      staffName: map['staff_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
