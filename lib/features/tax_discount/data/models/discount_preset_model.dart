// lib/features/tax_discount/data/models/discount_preset_model.dart

import '../../../../core/constants/db_constants.dart';
import '../../domain/entities/discount_preset_entity.dart';

class DiscountPresetModel extends DiscountPresetEntity {
  const DiscountPresetModel({
    required super.id,
    required super.name,
    required super.type,
    required super.value,
    required super.isActive,
    required super.createdAt,
  });

  factory DiscountPresetModel.fromMap(Map<String, dynamic> map) {
    return DiscountPresetModel(
      id: map[DbConstants.colId] as String,
      name: map[DbConstants.colName] as String,
      type: DiscountType.fromDbValue(map[DbConstants.colType] as String),
      value: (map[DbConstants.colValue] as num).toDouble(),
      isActive: (map[DbConstants.colIsActive] as int) == 1,
      createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DbConstants.colId: id,
      DbConstants.colName: name,
      DbConstants.colType: type.toDbValue(),
      DbConstants.colValue: value,
      DbConstants.colIsActive: isActive ? 1 : 0,
      DbConstants.colCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory DiscountPresetModel.fromEntity(DiscountPresetEntity entity) {
    return DiscountPresetModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      value: entity.value,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}
