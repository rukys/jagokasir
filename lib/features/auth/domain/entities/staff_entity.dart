// lib/features/auth/domain/entities/staff_entity.dart

enum StaffRole {
  owner,
  admin,
  kasir;

  String toDbValue() => name.toUpperCase();

  static StaffRole fromDbValue(String value) {
    return StaffRole.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => StaffRole.kasir,
    );
  }
}

class StaffEntity {
  final String id;
  final String name;
  final StaffRole role;
  final bool isActive;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const StaffEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.isActive,
    this.avatarPath,
    required this.createdAt,
    this.lastLoginAt,
  });

  StaffEntity copyWith({
    String? id,
    String? name,
    StaffRole? role,
    bool? isActive,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return StaffEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
