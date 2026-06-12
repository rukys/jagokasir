import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class SoftDeleteProductUsecase {
  final ProductRepository _repository;
  const SoftDeleteProductUsecase(this._repository);

  Future<Either<Failure, Unit>> call(String id) async {
    if (id.isEmpty) {
      return left(const ValidationFailure('ID produk tidak valid'));
    }
    // Cek relasi transaction_items dilakukan di repository implementation
    return _repository.softDelete(id);
  }
}
