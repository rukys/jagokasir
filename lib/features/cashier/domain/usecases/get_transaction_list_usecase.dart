import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionListUsecase {
  final TransactionRepository _repository;
  const GetTransactionListUsecase(this._repository);

  Future<Either<Failure, List<TransactionEntity>>> call({
    required StaffEntity currentStaff,
    TransactionStatus? status,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // Aturan bisnis: Kasir hanya boleh melihat transaksinya sendiri.
    // Owner/Admin dapat melihat semua transaksi (staffIdFilter = null).
    final String? staffIdFilter =
        currentStaff.role == StaffRole.kasir ? currentStaff.id : null;

    return _repository.getTransactionList(
      staffId: staffIdFilter,
      status: status,
      query: query,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
