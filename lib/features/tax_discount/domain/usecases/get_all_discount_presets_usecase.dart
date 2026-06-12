// lib/features/tax_discount/domain/usecases/get_all_discount_presets_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/discount_preset_entity.dart';
import '../repositories/discount_repository.dart';

class GetAllDiscountPresetsUsecase {
  final DiscountRepository _repository;

  const GetAllDiscountPresetsUsecase(this._repository);

  Future<Either<Failure, List<DiscountPresetEntity>>> call() {
    return _repository.getAllDiscountPresets();
  }
}
