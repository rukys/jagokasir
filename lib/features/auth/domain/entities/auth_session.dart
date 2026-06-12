// lib/features/auth/domain/entities/auth_session.dart

import 'staff_entity.dart';

class AuthSession {
  final StaffEntity staff;
  final DateTime loginAt;

  const AuthSession({
    required this.staff,
    required this.loginAt,
  });
}
