// lib/features/auth/domain/usecases/reset_staff_pin_usecase.dart

import 'dart:isolate';
import 'package:bcrypt/bcrypt.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class ResetStaffPinUsecase {
  final StaffRepository _repository;

  const ResetStaffPinUsecase(this._repository);

  Future<Either<Failure, bool>> call({
    required StaffRole currentUserRole,
    required String targetStaffId,
    required String newPin,
    required String confirmPin,
  }) async {
    // 1. Cek role
    if (currentUserRole != StaffRole.owner) {
      return left(const PermissionFailure('Hanya Owner yang dapat melakukan reset PIN'));
    }

    // 2. Validasi input
    if (newPin.length < 4 || newPin.length > 6 || int.tryParse(newPin) == null) {
      return left(const ValidationFailure('PIN baru harus berupa 4-6 digit angka'));
    }
    if (newPin != confirmPin) {
      return left(const ValidationFailure('Konfirmasi PIN baru tidak cocok'));
    }

    // 3. Hash PIN
    final pinHash = await Isolate.run(() => BCrypt.hashpw(newPin, BCrypt.gensalt()));

    // 4. Update
    return _repository.resetStaffPin(targetStaffId, pinHash);
  }
}
