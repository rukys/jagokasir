// lib/features/auth/domain/repositories/staff_repository.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff_entity.dart';

abstract class StaffRepository {
  Future<Either<Failure, bool>> checkOnboarding();
  Future<Either<Failure, List<StaffEntity>>> getAllStaffs();
  Future<Either<Failure, StaffEntity>> getStaffById(String id);
  Future<Either<Failure, StaffEntity>> createStaff(StaffEntity staff, String pinHash);
  Future<Either<Failure, StaffEntity>> updateStaff(StaffEntity staff);
  Future<Either<Failure, StaffEntity>> toggleStaffActive(String id, bool active);
  Future<Either<Failure, bool>> resetStaffPin(String id, String pinHash);
  Future<Either<Failure, String>> getPinHash(String id);
  Future<Either<Failure, StaffEntity>> updateLastLogin(String id);
  Future<Either<Failure, int>> getActiveOwnerCount();
}
