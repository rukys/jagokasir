// lib/features/tax_discount/domain/usecases/get_active_tax_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/tax_config_entity.dart';
import '../repositories/tax_repository.dart';

class GetActiveTaxUsecase {
  final TaxRepository _repository;

  const GetActiveTaxUsecase(this._repository);

  Future<Either<Failure, TaxConfigEntity?>> call() {
    return _repository.getActiveTax();
  }
}
