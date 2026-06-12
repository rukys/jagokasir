import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../../auth/domain/repositories/staff_repository.dart';
import '../repositories/transaction_repository.dart';

class VoidTransactionUsecase {
  final TransactionRepository _transactionRepository;
  final StaffRepository _staffRepository;

  const VoidTransactionUsecase(this._transactionRepository, this._staffRepository);

  Future<Either<Failure, bool>> call({
    required String transactionId,
    required String staffId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      return left(const ValidationFailure('Alasan pembatalan (void) wajib diisi'));
    }

    // Ambil detail staff untuk verifikasi role
    final staffResult = await _staffRepository.getStaffById(staffId);
    return staffResult.fold(
      (failure) => left(failure),
      (staff) async {
        // Otorisasi: Hanya OWNER dan ADMIN yang boleh melakukan void transaksi
        if (staff.role != StaffRole.owner && staff.role != StaffRole.admin) {
          return left(
            const PermissionFailure(
              'Akses ditolak. Hanya Owner atau Admin yang dapat membatalkan transaksi.',
            ),
          );
        }

        return _transactionRepository.voidTransaction(
          transactionId: transactionId,
          staffId: staffId,
          reason: reason.trim(),
        );
      },
    );
  }
}
