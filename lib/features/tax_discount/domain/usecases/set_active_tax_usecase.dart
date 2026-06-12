// lib/features/tax_discount/domain/usecases/set_active_tax_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/tax_repository.dart';

class SetActiveTaxUsecase {
  final TaxRepository _repository;

  const SetActiveTaxUsecase(this._repository);

  Future<Either<Failure, bool>> call(String id) {
    return _repository.setActiveTax(id);
  }
}
