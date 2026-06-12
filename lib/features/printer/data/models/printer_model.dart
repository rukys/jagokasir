// lib/features/printer/data/models/printer_model.dart

import '../../domain/entities/printer_entity.dart';

class PrinterModel extends PrinterEntity {
  const PrinterModel({
    required super.id,
    required super.name,
    required super.type,
    required super.address,
    required super.paperWidth,
    required super.isDefault,
    required super.isActive,
    required super.createdAt,
  });

  factory PrinterModel.fromMap(Map<String, dynamic> map) {
    return PrinterModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: (map['type'] as String) == 'WIFI' ? PrinterType.wifi : PrinterType.bluetooth,
      address: map['address'] as String,
      paperWidth: map['paper_width'] as int,
      isDefault: (map['is_default'] as int) == 1,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type == PrinterType.wifi ? 'WIFI' : 'BLUETOOTH',
      'address': address,
      'paper_width': paperWidth,
      'is_default': isDefault ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PrinterModel.fromEntity(PrinterEntity entity) {
    return PrinterModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      address: entity.address,
      paperWidth: entity.paperWidth,
      isDefault: entity.isDefault,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}
