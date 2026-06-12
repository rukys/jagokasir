import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class ToggleProductActiveUsecase {
  final ProductRepository _repository;
  const ToggleProductActiveUsecase(this._repository);

  Future<Either<Failure, ProductEntity>> call(String id) async {
    if (id.isEmpty) {
      return left(const ValidationFailure('ID produk tidak valid'));
    }
    return _repository.toggleActive(id);
  }
}
