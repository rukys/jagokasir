// lib/features/auth/domain/usecases/login_with_pin_usecase.dart

import 'dart:isolate';
import 'package:bcrypt/bcrypt.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class LoginWithPinUsecase {
  final StaffRepository _repository;

  const LoginWithPinUsecase(this._repository);

  Future<Either<Failure, StaffEntity>> call({
    required String staffId,
    required String pin,
  }) async {
    // 1. Ambil data staff berdasarkan ID
    final staffResult = await _repository.getStaffById(staffId);
    return staffResult.fold(
      (failure) => left(failure),
      (staff) async {
        // 2. Cek apakah aktif
        if (!staff.isActive) {
          return left(const ValidationFailure('Akun tidak aktif'));
        }

        // 3. Ambil pin_hash
        final hashResult = await _repository.getPinHash(staffId);
        return hashResult.fold(
          (failure) => left(failure),
          (storedHash) async {
            // 4. Verifikasi PIN
            try {
              final isPinValid = await Isolate.run(() => BCrypt.checkpw(pin, storedHash));
              if (!isPinValid) {
                return left(const ValidationFailure('PIN salah'));
              }
            } catch (e) {
              return left(const ValidationFailure('PIN salah'));
            }

            // 5. Update last login
            final updateResult = await _repository.updateLastLogin(staffId);
            return updateResult;
          },
        );
      },
    );
  }
}
