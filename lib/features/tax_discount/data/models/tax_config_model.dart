// lib/features/tax_discount/data/models/tax_config_model.dart

import '../../../../core/constants/db_constants.dart';
import '../../domain/entities/tax_config_entity.dart';

class TaxConfigModel extends TaxConfigEntity {
  const TaxConfigModel({
    required super.id,
    required super.name,
    required super.rate,
    required super.isInclusive,
    required super.isActive,
    required super.createdAt,
  });

  factory TaxConfigModel.fromMap(Map<String, dynamic> map) {
    return TaxConfigModel(
      id: map[DbConstants.colId] as String,
      name: map[DbConstants.colName] as String,
      rate: (map[DbConstants.colRate] as num).toDouble(),
      isInclusive: (map[DbConstants.colIsInclusive] as int) == 1,
      isActive: (map[DbConstants.colIsActive] as int) == 1,
      createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DbConstants.colId: id,
      DbConstants.colName: name,
      DbConstants.colRate: rate,
      DbConstants.colIsInclusive: isInclusive ? 1 : 0,
      DbConstants.colIsActive: isActive ? 1 : 0,
      DbConstants.colCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory TaxConfigModel.fromEntity(TaxConfigEntity entity) {
    return TaxConfigModel(
      id: entity.id,
      name: entity.name,
      rate: entity.rate,
      isInclusive: entity.isInclusive,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}
