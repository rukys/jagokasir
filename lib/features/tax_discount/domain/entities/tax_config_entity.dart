// lib/features/tax_discount/domain/entities/tax_config_entity.dart

class TaxConfigEntity {
  final String id;
  final String name;
  final double rate;
  final bool isInclusive;
  final bool isActive;
  final DateTime createdAt;

  const TaxConfigEntity({
    required this.id,
    required this.name,
    required this.rate,
    required this.isInclusive,
    required this.isActive,
    required this.createdAt,
  });

  TaxConfigEntity copyWith({
    String? id,
    String? name,
    double? rate,
    bool? isInclusive,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return TaxConfigEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      isInclusive: isInclusive ?? this.isInclusive,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
