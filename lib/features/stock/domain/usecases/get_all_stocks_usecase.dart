// lib/features/stock/domain/usecases/get_all_stocks_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/stock_entity.dart';
import '../repositories/stock_repository.dart';

class GetAllStocksUsecase {
  final StockRepository _repository;
  const GetAllStocksUsecase(this._repository);

  Future<Either<Failure, List<StockEntity>>> call() =>
      _repository.getAllStocks();
}
