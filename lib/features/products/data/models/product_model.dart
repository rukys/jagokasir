import '../../domain/entities/product_entity.dart';

/// Model produk — extends entity, tambah fromMap/toMap/copyWith.
/// Mendukung field 'category_name' dari hasil JOIN query.
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.sku,
    required super.sellingPrice,
    super.costPrice,
    required super.categoryId,
    required super.unit,
    super.barcode,
    super.imagePath,
    required super.isActive,
    required super.isDeleted,
    required super.createdAt,
    required super.updatedAt,
    super.categoryName,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      sku: map['sku'] as String,
      sellingPrice: (map['selling_price'] as num).toDouble(),
      costPrice: map['cost_price'] != null
          ? (map['cost_price'] as num).toDouble()
          : null,
      categoryId: map['category_id'] as String,
      unit: map['unit'] as String,
      barcode: map['barcode'] as String?,
      imagePath: map['image_path'] as String?,
      isActive: (map['is_active'] as int) == 1,
      isDeleted: (map['is_deleted'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      categoryName: map['category_name'] as String?,
    );
  }

  /// Untuk insert/update ke DB — tanpa category_name (field JOIN, bukan kolom DB).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'selling_price': sellingPrice,
      'cost_price': costPrice,
      'category_id': categoryId,
      'unit': unit,
      'barcode': barcode,
      'image_path': imagePath,
      'is_active': isActive ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? sku,
    double? sellingPrice,
    double? costPrice,
    String? categoryId,
    String? unit,
    String? barcode,
    String? imagePath,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      categoryId: categoryId ?? this.categoryId,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  /// Konversi dari entity parent ke model.
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      sku: entity.sku,
      sellingPrice: entity.sellingPrice,
      costPrice: entity.costPrice,
      categoryId: entity.categoryId,
      unit: entity.unit,
      barcode: entity.barcode,
      imagePath: entity.imagePath,
      isActive: entity.isActive,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      categoryName: entity.categoryName,
    );
  }
}
