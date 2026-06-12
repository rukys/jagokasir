// lib/features/tax_discount/domain/repositories/discount_repository.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/discount_preset_entity.dart';

abstract class DiscountRepository {
  Future<Either<Failure, List<DiscountPresetEntity>>> getAllDiscountPresets();
  Future<Either<Failure, List<DiscountPresetEntity>>> getActiveDiscountPresets();
  Future<Either<Failure, DiscountPresetEntity>> createDiscountPreset(DiscountPresetEntity discount);
  Future<Either<Failure, DiscountPresetEntity>> updateDiscountPreset(DiscountPresetEntity discount);
  Future<Either<Failure, DiscountPresetEntity>> toggleDiscountPreset(String id, bool active);
  Future<Either<Failure, bool>> deleteDiscountPreset(String id);
}
