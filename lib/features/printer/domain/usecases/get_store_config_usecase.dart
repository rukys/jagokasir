// lib/features/printer/domain/usecases/get_store_config_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/store_config_entity.dart';
import '../repositories/store_config_repository.dart';

class GetStoreConfigUsecase {
  final StoreConfigRepository _repository;
  const GetStoreConfigUsecase(this._repository);

  Future<Either<Failure, StoreConfigEntity>> call() {
    return _repository.getStoreConfig();
  }
}
