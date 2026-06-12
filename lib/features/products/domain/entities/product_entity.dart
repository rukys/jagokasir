/// Entity produk. Pure Dart class — tidak boleh import Flutter/package eksternal.
class ProductEntity {
  final String id;
  final String name;
  final String sku;
  final double sellingPrice;

  /// Harga modal, nullable (tidak wajib diisi).
  final double? costPrice;
  final String categoryId;

  /// Satuan: pcs, kg, liter, dll.
  final String unit;

  /// Barcode, nullable.
  final String? barcode;

  /// Path lokal foto produk, nullable.
  final String? imagePath;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Nama kategori dari JOIN query — hanya untuk display, tidak disimpan ke DB.
  final String? categoryName;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.sku,
    required this.sellingPrice,
    this.costPrice,
    required this.categoryId,
    required this.unit,
    this.barcode,
    this.imagePath,
    required this.isActive,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ProductEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProductEntity(id: $id, name: $name, sku: $sku)';
}
