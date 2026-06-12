// lib/features/tax_discount/domain/usecases/toggle_discount_preset_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/discount_preset_entity.dart';
import '../repositories/discount_repository.dart';

class ToggleDiscountPresetUsecase {
  final DiscountRepository _repository;

  const ToggleDiscountPresetUsecase(this._repository);

  Future<Either<Failure, DiscountPresetEntity>> call({
    required String id,
    required bool isActive,
  }) {
    return _repository.toggleDiscountPreset(id, isActive);
  }
}
