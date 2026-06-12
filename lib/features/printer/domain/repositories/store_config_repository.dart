// lib/features/printer/domain/repositories/store_config_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/store_config_entity.dart';

abstract interface class StoreConfigRepository {
  Future<Either<Failure, StoreConfigEntity>> getStoreConfig();
  Future<Either<Failure, void>> updateStoreConfig(StoreConfigEntity config);
}
