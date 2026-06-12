// lib/features/tax_discount/domain/usecases/delete_tax_config_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/tax_repository.dart';

class DeleteTaxConfigUsecase {
  final TaxRepository _repository;

  const DeleteTaxConfigUsecase(this._repository);

  Future<Either<Failure, bool>> call(String id) async {
    final activeTaxResult = await _repository.getActiveTax();
    return activeTaxResult.fold(
      (failure) => left(failure),
      (activeTax) {
        if (activeTax != null && activeTax.id == id) {
          return left(const ValidationFailure('Nonaktifkan pajak terlebih dahulu sebelum menghapus'));
        }
        return _repository.deleteTaxConfig(id);
      },
    );
  }
}
