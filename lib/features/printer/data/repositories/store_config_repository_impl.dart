// lib/features/printer/data/repositories/store_config_repository_impl.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/store_config_entity.dart';
import '../../domain/repositories/store_config_repository.dart';
import '../datasources/store_config_datasource.dart';
import '../models/store_config_model.dart';

class StoreConfigRepositoryImpl implements StoreConfigRepository {
  final StoreConfigDatasource _datasource;
  const StoreConfigRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, StoreConfigEntity>> getStoreConfig() async {
    try {
      final config = await _datasource.getStoreConfig();
      return right(config);
    } catch (error) {
      return left(DbFailure('Gagal mengambil konfigurasi toko: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> updateStoreConfig(StoreConfigEntity config) async {
    try {
      final model = StoreConfigModel.fromEntity(config);
      await _datasource.updateStoreConfig(model);
      return right(null);
    } catch (error) {
      return left(DbFailure('Gagal memperbarui konfigurasi toko: $error'));
    }
  }
}
