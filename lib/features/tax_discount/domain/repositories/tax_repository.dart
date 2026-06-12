// lib/features/tax_discount/domain/repositories/tax_repository.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/tax_config_entity.dart';

abstract class TaxRepository {
  Future<Either<Failure, List<TaxConfigEntity>>> getAllTaxConfigs();
  Future<Either<Failure, TaxConfigEntity?>> getActiveTax();
  Future<Either<Failure, TaxConfigEntity>> createTaxConfig(TaxConfigEntity tax);
  Future<Either<Failure, TaxConfigEntity>> updateTaxConfig(TaxConfigEntity tax);
  Future<Either<Failure, bool>> setActiveTax(String id);
  Future<Either<Failure, bool>> deleteTaxConfig(String id);
}
