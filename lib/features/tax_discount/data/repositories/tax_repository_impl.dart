// lib/features/tax_discount/data/repositories/tax_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/tax_config_entity.dart';
import '../../domain/repositories/tax_repository.dart';
import '../datasources/tax_local_datasource.dart';
import '../models/tax_config_model.dart';

class TaxRepositoryImpl implements TaxRepository {
  final TaxLocalDatasource _localDatasource;

  const TaxRepositoryImpl(this._localDatasource);

  @override
  Future<Either<Failure, List<TaxConfigEntity>>> getAllTaxConfigs() async {
    try {
      final models = await _localDatasource.getAllTaxConfigs();
      return right(models);
    } catch (error) {
      return left(DbFailure('Gagal mengambil daftar pajak: $error'));
    }
  }

  @override
  Future<Either<Failure, TaxConfigEntity?>> getActiveTax() async {
    try {
      final model = await _localDatasource.getActiveTax();
      return right(model);
    } catch (error) {
      return left(DbFailure('Gagal mengambil pajak aktif: $error'));
    }
  }

  @override
  Future<Either<Failure, TaxConfigEntity>> createTaxConfig(TaxConfigEntity tax) async {
    try {
      final model = TaxConfigModel.fromEntity(tax);
      final result = await _localDatasource.createTaxConfig(model);
      return right(result);
    } catch (error) {
      return left(DbFailure('Gagal menyimpan konfigurasi pajak baru: $error'));
    }
  }

  @override
  Future<Either<Failure, TaxConfigEntity>> updateTaxConfig(TaxConfigEntity tax) async {
    try {
      final model = TaxConfigModel.fromEntity(tax);
      final result = await _localDatasource.updateTaxConfig(model);
      return right(result);
    } catch (error) {
      return left(DbFailure('Gagal memperbarui konfigurasi pajak: $error'));
    }
  }

  @override
  Future<Either<Failure, bool>> setActiveTax(String id) async {
    try {
      final success = await _localDatasource.setActiveTax(id);
      return right(success);
    } catch (error) {
      return left(DbFailure('Gagal mengaktifkan pajak: $error'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTaxConfig(String id) async {
    try {
      final success = await _localDatasource.deleteTaxConfig(id);
      return right(success);
    } catch (error) {
      return left(DbFailure('Gagal menghapus konfigurasi pajak: $error'));
    }
  }
}
