// lib/features/stock/domain/usecases/get_low_stock_products_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/stock_entity.dart';
import '../repositories/stock_repository.dart';

class GetLowStockProductsUsecase {
  final StockRepository _repository;
  const GetLowStockProductsUsecase(this._repository);

  Future<Either<Failure, List<StockEntity>>> call() =>
      _repository.getLowStockProducts();
}
