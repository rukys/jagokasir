// lib/features/auth/data/repositories/staff_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_local_datasource.dart';
import '../models/staff_model.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffLocalDatasource _datasource;

  const StaffRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, bool>> checkOnboarding() async {
    try {
      final result = await _datasource.checkOnboarding();
      return right(result);
    } catch (e) {
      return left(DbFailure('Gagal memeriksa status onboarding: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StaffEntity>>> getAllStaffs() async {
    try {
      final result = await _datasource.getAllStaffs();
      return right(result);
    } catch (e) {
      return left(DbFailure('Gagal mengambil data staff: $e'));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> getStaffById(String id) async {
    try {
      final result = await _datasource.getStaffById(id);
      if (result == null) {
        return left(const NotFoundFailure('Staff tidak ditemukan'));
      }
      return right(result);
    } catch (e) {
      return left(DbFailure('Gagal mengambil data staff: $e'));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> createStaff(StaffEntity staff, String pinHash) async {
    try {
      final model = StaffModel.fromEntity(staff);
      await _datasource.createStaff(model, pinHash);
      return right(staff);
    } catch (e) {
      return left(DbFailure('Gagal membuat staff baru: $e'));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> updateStaff(StaffEntity staff) async {
    try {
      final model = StaffModel.fromEntity(staff);
      await _datasource.updateStaff(model);
      return right(staff);
    } catch (e) {
      return left(DbFailure('Gagal memperbarui data staff: $e'));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> toggleStaffActive(String id, bool active) async {
    try {
      await _datasource.toggleStaffActive(id, active ? 1 : 0);
      final staff = await _datasource.getStaffById(id);
      if (staff == null) {
        return left(const NotFoundFailure('Staff tidak ditemukan setelah update'));
      }
      return right(staff);
    } catch (e) {
      return left(DbFailure('Gagal memperbarui status aktif staff: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> resetStaffPin(String id, String pinHash) async {
    try {
      await _datasource.resetStaffPin(id, pinHash);
      return right(true);
    } catch (e) {
      return left(DbFailure('Gagal mereset PIN staff: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getPinHash(String id) async {
    try {
      final hash = await _datasource.getPinHash(id);
      if (hash == null) {
        return left(const NotFoundFailure('PIN hash tidak ditemukan'));
      }
      return right(hash);
    } catch (e) {
      return left(DbFailure('Gagal mengambil PIN hash: $e'));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> updateLastLogin(String id) async {
    try {
      final nowStr = DateTime.now().toIso8601String();
      await _datasource.updateLastLogin(id, nowStr);
      final staff = await _datasource.getStaffById(id);
      if (staff == null) {
        return left(const NotFoundFailure('Staff tidak ditemukan setelah update login'));
      }
      return right(staff);
    } catch (e) {
      return left(DbFailure('Gagal memperbarui waktu login terakhir: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getActiveOwnerCount() async {
    try {
      final count = await _datasource.getActiveOwnerCount();
      return right(count);
    } catch (e) {
      return left(DbFailure('Gagal menghitung jumlah Owner aktif: $e'));
    }
  }
}
