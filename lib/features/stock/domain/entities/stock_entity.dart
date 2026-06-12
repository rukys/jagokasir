// lib/features/stock/domain/entities/stock_entity.dart

/// Representasi data stok produk.
/// Berisi data dari tabel `stocks` + joined fields dari `products`.
class StockEntity {
  final String id;
  final String productId;
  final double currentStock;
  final double minimumStock;
  final bool trackStock;

  // ── Joined dari products (untuk display) ───────────────────────────────────
  final String productName;
  final String productSku;
  final String productUnit;
  final String? productImagePath;

  const StockEntity({
    required this.id,
    required this.productId,
    required this.currentStock,
    required this.minimumStock,
    required this.trackStock,
    required this.productName,
    required this.productSku,
    required this.productUnit,
    this.productImagePath,
  });

  /// Stok dianggap rendah jika `track_stock = true` dan
  /// `current_stock <= minimum_stock`.
  bool get isLowStock => trackStock && currentStock <= minimumStock;

  StockEntity copyWith({
    String? id,
    String? productId,
    double? currentStock,
    double? minimumStock,
    bool? trackStock,
    String? productName,
    String? productSku,
    String? productUnit,
    String? productImagePath,
  }) {
    return StockEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      trackStock: trackStock ?? this.trackStock,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      productUnit: productUnit ?? this.productUnit,
      productImagePath: productImagePath ?? this.productImagePath,
    );
  }
}
