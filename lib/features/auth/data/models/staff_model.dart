// lib/features/auth/data/models/staff_model.dart

import '../../domain/entities/staff_entity.dart';

class StaffModel extends StaffEntity {
  const StaffModel({
    required super.id,
    required super.name,
    required super.role,
    required super.isActive,
    super.avatarPath,
    required super.createdAt,
    super.lastLoginAt,
  });

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      id: map['id'] as String,
      name: map['name'] as String,
      role: StaffRole.fromDbValue(map['role'] as String),
      isActive: (map['is_active'] as int) == 1,
      avatarPath: map['avatar_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role.toDbValue(),
      'is_active': isActive ? 1 : 0,
      'avatar_path': avatarPath,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  factory StaffModel.fromEntity(StaffEntity entity) {
    return StaffModel(
      id: entity.id,
      name: entity.name,
      role: entity.role,
      isActive: entity.isActive,
      avatarPath: entity.avatarPath,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
    );
  }
}
