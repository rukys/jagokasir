// lib/features/backup/domain/usecases/share_backup_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/backup_repository.dart';

class ShareBackupUsecase {
  final BackupRepository _repository;
  const ShareBackupUsecase(this._repository);

  Future<Either<Failure, Unit>> call(String filePath) async {
    if (filePath.isEmpty) {
      return left(const ValidationFailure('Path file backup tidak boleh kosong'));
    }
    return _repository.shareBackup(filePath);
  }
}
