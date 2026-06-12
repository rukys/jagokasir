// lib/features/backup/domain/usecases/delete_backup_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/backup_repository.dart';

class DeleteBackupUsecase {
  final BackupRepository _repository;
  const DeleteBackupUsecase(this._repository);

  Future<Either<Failure, Unit>> call(String id) async {
    if (id.isEmpty) {
      return left(const ValidationFailure('ID backup tidak boleh kosong'));
    }
    return _repository.deleteBackup(id);
  }
}
