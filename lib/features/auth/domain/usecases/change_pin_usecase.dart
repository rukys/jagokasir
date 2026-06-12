// lib/features/auth/domain/usecases/change_pin_usecase.dart

import 'dart:isolate';
import 'package:bcrypt/bcrypt.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/staff_repository.dart';

class ChangePinUsecase {
  final StaffRepository _repository;

  const ChangePinUsecase(this._repository);

  Future<Either<Failure, bool>> call({
    required String staffId,
    required String oldPin,
    required String newPin,
    required String confirmPin,
  }) async {
    // 1. Get old pin hash
    final hashResult = await _repository.getPinHash(staffId);
    return hashResult.fold(
      (failure) => left(failure),
      (storedHash) async {
        // 2. Verify old pin matches stored hash
        try {
          final isPinValid = await Isolate.run(() => BCrypt.checkpw(oldPin, storedHash));
          if (!isPinValid) {
            return left(const ValidationFailure('PIN lama salah'));
          }
        } catch (_) {
          return left(const ValidationFailure('PIN lama salah'));
        }

        // 3. Validate new pin format
        if (newPin.length < 4 || newPin.length > 6 || int.tryParse(newPin) == null) {
          return left(const ValidationFailure('PIN baru harus berupa 4-6 digit angka'));
        }
        if (newPin != confirmPin) {
          return left(const ValidationFailure('Konfirmasi PIN baru tidak cocok'));
        }
        if (oldPin == newPin) {
          return left(const ValidationFailure('PIN baru tidak boleh sama dengan PIN lama'));
        }

        // 4. Hash new PIN
        final newPinHash = await Isolate.run(() => BCrypt.hashpw(newPin, BCrypt.gensalt()));

        // 5. Save new PIN hash
        return _repository.resetStaffPin(staffId, newPinHash);
      },
    );
  }
}
