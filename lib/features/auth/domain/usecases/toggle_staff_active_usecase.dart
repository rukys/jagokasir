// lib/features/auth/domain/usecases/toggle_staff_active_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class ToggleStaffActiveUsecase {
  final StaffRepository _repository;

  const ToggleStaffActiveUsecase(this._repository);

  Future<Either<Failure, StaffEntity>> call({
    required String id,
    required bool active,
  }) async {
    // 1. Ambil data staff saat ini
    final currentStaffResult = await _repository.getStaffById(id);
    return currentStaffResult.fold(
      (failure) => left(failure),
      (staff) async {
        // 2. Jika menonaktifkan Owner, cek apakah ini Owner aktif terakhir
        if (staff.role == StaffRole.owner && !active) {
          final countResult = await _repository.getActiveOwnerCount();
          final isPrevented = countResult.fold(
            (f) => true,
            (count) => count <= 1,
          );
          if (isPrevented) {
            return left(const ValidationFailure('Gagal menonaktifkan. Minimal harus ada 1 Owner aktif di sistem.'));
          }
        }

        // 3. Jalankan toggle
        return _repository.toggleStaffActive(id, active);
      },
    );
  }
}
