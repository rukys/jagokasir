// lib/features/backup/domain/usecases/restore_backup_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/backup_repository.dart';

class RestoreBackupUsecase {
  final BackupRepository _repository;
  const RestoreBackupUsecase(this._repository);

  Future<Either<Failure, Unit>> call(String filePath) async {
    if (filePath.isEmpty) {
      return left(const ValidationFailure('Path file backup tidak boleh kosong'));
    }
    return _repository.restoreBackup(filePath);
  }
}
