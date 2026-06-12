import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetAllProductsUsecase {
  final ProductRepository _repository;
  const GetAllProductsUsecase(this._repository);

  Future<Either<Failure, List<ProductEntity>>> call() =>
      _repository.getAll();
}
