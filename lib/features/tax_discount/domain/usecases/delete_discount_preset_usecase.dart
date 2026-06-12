// lib/features/tax_discount/domain/usecases/delete_discount_preset_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/discount_repository.dart';

class DeleteDiscountPresetUsecase {
  final DiscountRepository _repository;

  const DeleteDiscountPresetUsecase(this._repository);

  Future<Either<Failure, bool>> call(String id) {
    return _repository.deleteDiscountPreset(id);
  }
}
