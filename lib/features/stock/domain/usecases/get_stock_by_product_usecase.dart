// lib/features/stock/domain/usecases/get_stock_by_product_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/stock_entity.dart';
import '../repositories/stock_repository.dart';

class GetStockByProductUsecase {
  final StockRepository _repository;
  const GetStockByProductUsecase(this._repository);

  Future<Either<Failure, StockEntity>> call(String productId) {
    if (productId.trim().isEmpty) {
      return Future.value(
        left(const ValidationFailure('Product ID tidak boleh kosong')),
      );
    }
    return _repository.getStockByProduct(productId);
  }
}
