// lib/features/printer/data/models/store_config_model.dart

import '../../domain/entities/store_config_entity.dart';

class StoreConfigModel extends StoreConfigEntity {
  const StoreConfigModel({
    required super.id,
    required super.storeName,
    super.storeAddress,
    super.storePhone,
    super.receiptFooter,
    super.logoPath,
    required super.autoPrint,
    required super.updatedAt,
  });

  factory StoreConfigModel.fromMap(Map<String, dynamic> map) {
    return StoreConfigModel(
      id: map['id'] as String,
      storeName: map['store_name'] as String,
      storeAddress: map['store_address'] as String?,
      storePhone: map['store_phone'] as String?,
      receiptFooter: map['receipt_footer'] as String?,
      logoPath: map['logo_path'] as String?,
      autoPrint: (map['auto_print'] as int) == 1,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_name': storeName,
      'store_address': storeAddress,
      'store_phone': storePhone,
      'receipt_footer': receiptFooter,
      'logo_path': logoPath,
      'auto_print': autoPrint ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StoreConfigModel.fromEntity(StoreConfigEntity entity) {
    return StoreConfigModel(
      id: entity.id,
      storeName: entity.storeName,
      storeAddress: entity.storeAddress,
      storePhone: entity.storePhone,
      receiptFooter: entity.receiptFooter,
      logoPath: entity.logoPath,
      autoPrint: entity.autoPrint,
      updatedAt: entity.updatedAt,
    );
  }
}
