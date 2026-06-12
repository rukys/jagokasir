// lib/features/tax_discount/domain/entities/discount_preset_entity.dart

enum DiscountType {
  percentage,
  nominal;

  String toDbValue() => name.toUpperCase();

  static DiscountType fromDbValue(String value) {
    return DiscountType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => DiscountType.percentage,
    );
  }
}

class DiscountPresetEntity {
  final String id;
  final String name;
  final DiscountType type;
  final double value;
  final bool isActive;
  final DateTime createdAt;

  const DiscountPresetEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.isActive,
    required this.createdAt,
  });

  DiscountPresetEntity copyWith({
    String? id,
    String? name,
    DiscountType? type,
    double? value,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return DiscountPresetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
