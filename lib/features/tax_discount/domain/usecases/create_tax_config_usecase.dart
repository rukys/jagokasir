// lib/features/tax_discount/domain/usecases/create_tax_config_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../entities/tax_config_entity.dart';
import '../repositories/tax_repository.dart';

class CreateTaxConfigUsecase {
  final TaxRepository _repository;

  const CreateTaxConfigUsecase(this._repository);

  Future<Either<Failure, TaxConfigEntity>> call({
    required String name,
    required double rate,
    required bool isInclusive,
  }) async {
    if (name.trim().isEmpty) {
      return left(const ValidationFailure('Nama pajak tidak boleh kosong'));
    }
    if (rate < 0.0 || rate > 100.0) {
      return left(const ValidationFailure('Persentase pajak harus antara 0.0% dan 100.0%'));
    }

    final tax = TaxConfigEntity(
      id: UuidGenerator.generate(),
      name: name.trim(),
      rate: rate,
      isInclusive: isInclusive,
      isActive: false, // Default tidak aktif saat baru dibuat
      createdAt: DateTime.now(),
    );

    return _repository.createTaxConfig(tax);
  }
}
