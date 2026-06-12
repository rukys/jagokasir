// lib/features/tax_discount/domain/usecases/update_tax_config_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/tax_config_entity.dart';
import '../repositories/tax_repository.dart';

class UpdateTaxConfigUsecase {
  final TaxRepository _repository;

  const UpdateTaxConfigUsecase(this._repository);

  Future<Either<Failure, TaxConfigEntity>> call({
    required String id,
    required String name,
    required double rate,
    required bool isInclusive,
    required bool isActive,
    required DateTime createdAt,
  }) async {
    if (name.trim().isEmpty) {
      return left(const ValidationFailure('Nama pajak tidak boleh kosong'));
    }
    if (rate < 0.0 || rate > 100.0) {
      return left(const ValidationFailure('Persentase pajak harus antara 0.0% dan 100.0%'));
    }

    final updatedTax = TaxConfigEntity(
      id: id,
      name: name.trim(),
      rate: rate,
      isInclusive: isInclusive,
      isActive: isActive,
      createdAt: createdAt,
    );

    return _repository.updateTaxConfig(updatedTax);
  }
}
