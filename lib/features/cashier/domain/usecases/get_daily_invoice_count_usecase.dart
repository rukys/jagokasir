import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/transaction_repository.dart';

class GetDailyInvoiceCountUsecase {
  final TransactionRepository _repository;
  const GetDailyInvoiceCountUsecase(this._repository);

  Future<Either<Failure, int>> call(String dateStr) {
    if (dateStr.isEmpty) {
      return Future.value(left(const ValidationFailure('Date string cannot be empty')));
    }
    return _repository.getDailyInvoiceCount(dateStr);
  }
}
