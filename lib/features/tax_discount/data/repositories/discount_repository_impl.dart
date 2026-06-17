// lib/features/tax_discount/data/repositories/discount_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/discount_preset_entity.dart';
import '../../domain/repositories/discount_repository.dart';
import '../datasources/discount_local_datasource.dart';
import '../models/discount_preset_model.dart';

class DiscountRepositoryImpl implements DiscountRepository {
  final DiscountLocalDatasource _localDatasource;

  const DiscountRepositoryImpl(this._localDatasource);

  @override
  Future<Either<Failure, List<DiscountPresetEntity>>> getAllDiscountPresets() async {
    try {
      final models = await _localDatasource.getAllDiscountPresets();
      return right(models);
    } catch (error) {
      return left(DbFailure('Gagal mengambil daftar preset diskon: $error'));
    }
  }

  @override
  Future<Either<Failure, List<DiscountPresetEntity>>> getActiveDiscountPresets() async {
    try {
      final models = await _localDatasource.getActiveDiscountPresets();
      return right(models);
    } catch (error) {
      return left(DbFailure('Gagal mengambil preset diskon aktif: $error'));
    }
  }

  @override
  Future<Either<Failure, DiscountPresetEntity>> createDiscountPreset(DiscountPresetEntity discount) async {
    try {
      final model = DiscountPresetModel.fromEntity(discount);
      final result = await _localDatasource.createDiscountPreset(model);
      return right(result);
    } catch (error) {
      return left(DbFailure('Gagal menyimpan preset diskon baru: $error'));
    }
  }

  @override
  Future<Either<Failure, DiscountPresetEntity>> updateDiscountPreset(DiscountPresetEntity discount) async {
    try {
      final model = DiscountPresetModel.fromEntity(discount);
      final result = await _localDatasource.updateDiscountPreset(model);
      return right(result);
    } catch (error) {
      return left(DbFailure('Gagal memperbarui preset diskon: $error'));
    }
  }

  @override
  Future<Either<Failure, DiscountPresetEntity>> toggleDiscountPreset(String id, bool active) async {
    try {
      final result = await _localDatasource.toggleDiscountPreset(id, active);
      return right(result);
    } catch (error) {
      return left(DbFailure('Gagal mengubah status aktif preset diskon: $error'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDiscountPreset(String id) async {
    try {
      final success = await _localDatasource.deleteDiscountPreset(id);
      return right(success);
    } catch (error) {
      return left(DbFailure('Gagal menghapus preset diskon: $error'));
    }
  }
}
