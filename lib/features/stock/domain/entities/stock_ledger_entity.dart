// lib/features/stock/domain/entities/stock_ledger_entity.dart

/// Representasi satu entri riwayat mutasi stok (ledger).
/// Berisi data dari tabel `stock_ledger` + joined `staff_name` dari `staffs`.
class StockLedgerEntity {
  final String id;
  final String productId;

  /// Positif = stok masuk, Negatif = stok keluar.
  final double changeAmount;

  /// Stok setelah mutasi ini diterapkan.
  final double stockAfter;

  /// Alasan mutasi: 'SALE' | 'RESTOCK' | 'ADJUSTMENT' | 'VOID'
  final String reason;

  /// ID referensi (transaction id) — hanya ada untuk reason SALE dan VOID.
  final String? referenceId;

  final String? note;
  final String? staffId;

  /// Nama staff — hasil join dari tabel `staffs`.
  final String? staffName;

  final DateTime createdAt;

  const StockLedgerEntity({
    required this.id,
    required this.productId,
    required this.changeAmount,
    required this.stockAfter,
    required this.reason,
    this.referenceId,
    this.note,
    this.staffId,
    this.staffName,
    required this.createdAt,
  });

  bool get isIncoming => changeAmount > 0;
  bool get isOutgoing => changeAmount < 0;
}
