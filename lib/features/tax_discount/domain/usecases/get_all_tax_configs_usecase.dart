// lib/features/tax_discount/domain/usecases/get_all_tax_configs_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/tax_config_entity.dart';
import '../repositories/tax_repository.dart';

class GetAllTaxConfigsUsecase {
  final TaxRepository _repository;

  const GetAllTaxConfigsUsecase(this._repository);

  Future<Either<Failure, List<TaxConfigEntity>>> call() {
    return _repository.getAllTaxConfigs();
  }
}
