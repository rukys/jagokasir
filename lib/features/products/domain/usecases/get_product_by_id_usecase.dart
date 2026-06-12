import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductByIdUsecase {
  final ProductRepository _repository;
  const GetProductByIdUsecase(this._repository);

  Future<Either<Failure, ProductEntity>> call(String id) async {
    if (id.isEmpty) {
      return left(const ValidationFailure('ID produk tidak valid'));
    }
    return _repository.getById(id);
  }
}
