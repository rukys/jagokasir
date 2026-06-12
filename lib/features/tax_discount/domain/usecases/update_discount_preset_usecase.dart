// lib/features/tax_discount/domain/usecases/update_discount_preset_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/discount_preset_entity.dart';
import '../repositories/discount_repository.dart';

class UpdateDiscountPresetUsecase {
  final DiscountRepository _repository;

  const UpdateDiscountPresetUsecase(this._repository);

  Future<Either<Failure, DiscountPresetEntity>> call({
    required String id,
    required String name,
    required DiscountType type,
    required double value,
    required bool isActive,
    required DateTime createdAt,
  }) async {
    if (name.trim().isEmpty) {
      return left(const ValidationFailure('Nama preset diskon tidak boleh kosong'));
    }
    if (value < 0) {
      return left(const ValidationFailure('Nilai diskon tidak boleh negatif'));
    }
    if (type == DiscountType.percentage && value > 100) {
      return left(const ValidationFailure('Persentase diskon tidak boleh melebihi 100%'));
    }

    final updatedDiscount = DiscountPresetEntity(
      id: id,
      name: name.trim(),
      type: type,
      value: value,
      isActive: isActive,
      createdAt: createdAt,
    );

    return _repository.updateDiscountPreset(updatedDiscount);
  }
}
