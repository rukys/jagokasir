// lib/features/stock/domain/usecases/get_stock_ledger_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/stock_ledger_entity.dart';
import '../repositories/stock_repository.dart';

class GetStockLedgerUsecase {
  final StockRepository _repository;
  const GetStockLedgerUsecase(this._repository);

  Future<Either<Failure, List<StockLedgerEntity>>> call(String productId) {
    if (productId.trim().isEmpty) {
      return Future.value(
        left(const ValidationFailure('Product ID tidak boleh kosong')),
      );
    }
    return _repository.getStockLedger(productId);
  }
}
