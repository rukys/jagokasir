// lib/features/printer/domain/entities/printer_entity.dart

enum PrinterType { bluetooth, wifi }

class PrinterEntity {
  final String id;
  final String name;
  final PrinterType type;
  final String address; // MAC address (BT) atau IP:Port (WiFi)
  final int paperWidth; // 58 atau 80
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;

  const PrinterEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.paperWidth,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
  });

  PrinterEntity copyWith({
    String? id,
    String? name,
    PrinterType? type,
    String? address,
    int? paperWidth,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PrinterEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      paperWidth: paperWidth ?? this.paperWidth,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
