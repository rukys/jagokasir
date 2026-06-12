// lib/features/printer/domain/usecases/update_store_config_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/store_config_entity.dart';
import '../repositories/store_config_repository.dart';

class UpdateStoreConfigUsecase {
  final StoreConfigRepository _repository;
  const UpdateStoreConfigUsecase(this._repository);

  Future<Either<Failure, void>> call(StoreConfigEntity config) {
    if (config.storeName.trim().isEmpty) {
      return Future.value(left(const ValidationFailure('Nama toko tidak boleh kosong')));
    }
    return _repository.updateStoreConfig(config);
  }
}
