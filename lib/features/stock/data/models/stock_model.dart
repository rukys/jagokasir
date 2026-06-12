// lib/features/stock/data/models/stock_model.dart

import '../../domain/entities/stock_entity.dart';

/// Model stok — extends [StockEntity], tambah fromMap / toMap / fromEntity.
/// `productName`, `productSku`, `productUnit`, `productImagePath` diisi dari
/// hasil JOIN query (bukan kolom asli tabel `stocks`).
class StockModel extends StockEntity {
  const StockModel({
    required super.id,
    required super.productId,
    required super.currentStock,
    required super.minimumStock,
    required super.trackStock,
    required super.productName,
    required super.productSku,
    required super.productUnit,
    super.productImagePath,
  });

  factory StockModel.fromMap(Map<String, dynamic> map) {
    return StockModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      currentStock: (map['current_stock'] as num).toDouble(),
      minimumStock: (map['minimum_stock'] as num).toDouble(),
      trackStock: (map['track_stock'] as int) == 1,
      productName: map['product_name'] as String? ?? '',
      productSku: map['product_sku'] as String? ?? '',
      productUnit: map['product_unit'] as String? ?? 'pcs',
      productImagePath: map['product_image_path'] as String?,
    );
  }

  /// Hanya kolom milik tabel `stocks` — tanpa joined fields.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'current_stock': currentStock,
      'minimum_stock': minimumStock,
      'track_stock': trackStock ? 1 : 0,
    };
  }

  factory StockModel.fromEntity(StockEntity entity) {
    return StockModel(
      id: entity.id,
      productId: entity.productId,
      currentStock: entity.currentStock,
      minimumStock: entity.minimumStock,
      trackStock: entity.trackStock,
      productName: entity.productName,
      productSku: entity.productSku,
      productUnit: entity.productUnit,
      productImagePath: entity.productImagePath,
    );
  }
}
