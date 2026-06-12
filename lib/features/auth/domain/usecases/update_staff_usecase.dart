// lib/features/auth/domain/usecases/update_staff_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class UpdateStaffUsecase {
  final StaffRepository _repository;

  const UpdateStaffUsecase(this._repository);

  Future<Either<Failure, StaffEntity>> call({
    required String id,
    required String name,
    required StaffRole role,
  }) async {
    if (name.trim().isEmpty) {
      return left(const ValidationFailure('Nama tidak boleh kosong'));
    }

    // 1. Dapatkan data staff saat ini
    final currentStaffResult = await _repository.getStaffById(id);
    return currentStaffResult.fold(
      (failure) => left(failure),
      (currentStaff) async {
        // 2. Jika merubah dari Owner ke role lain, cek apakah ini Owner aktif terakhir
        if (currentStaff.role == StaffRole.owner && role != StaffRole.owner && currentStaff.isActive) {
          final countResult = await _repository.getActiveOwnerCount();
          final isPrevented = countResult.fold(
            (f) => true,
            (count) => count <= 1,
          );
          if (isPrevented) {
            return left(const ValidationFailure('Gagal merubah role. Minimal harus ada 1 Owner aktif di sistem.'));
          }
        }

        // 3. Update data
        final updatedStaff = currentStaff.copyWith(
          name: name.trim(),
          role: role,
        );

        return _repository.updateStaff(updatedStaff);
      },
    );
  }
}
