import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionByIdUsecase {
  final TransactionRepository _repository;
  const GetTransactionByIdUsecase(this._repository);

  Future<Either<Failure, TransactionEntity>> call(String id) {
    if (id.isEmpty) {
      return Future.value(left(const ValidationFailure('ID transaksi tidak boleh kosong')));
    }
    return _repository.getTransactionById(id);
  }
}
