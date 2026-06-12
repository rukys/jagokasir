// lib/features/printer/domain/entities/store_config_entity.dart

class StoreConfigEntity {
  final String id; // selalu 'store-config'
  final String storeName;
  final String? storeAddress;
  final String? storePhone;
  final String? receiptFooter;
  final String? logoPath;
  final bool autoPrint;
  final DateTime updatedAt;

  const StoreConfigEntity({
    required this.id,
    required this.storeName,
    this.storeAddress,
    this.storePhone,
    this.receiptFooter,
    this.logoPath,
    required this.autoPrint,
    required this.updatedAt,
  });

  StoreConfigEntity copyWith({
    String? id,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? receiptFooter,
    String? logoPath,
    bool? autoPrint,
    DateTime? updatedAt,
  }) {
    return StoreConfigEntity(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      logoPath: logoPath ?? this.logoPath,
      autoPrint: autoPrint ?? this.autoPrint,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
