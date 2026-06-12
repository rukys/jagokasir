/// Entity kategori produk. Pure Dart class — tidak boleh import Flutter/package eksternal.
class CategoryEntity {
  final String id;
  final String name;

  /// Format '#RRGGBB', nullable.
  final String? colorHex;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.colorHex,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CategoryEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryEntity(id: $id, name: $name)';
}
