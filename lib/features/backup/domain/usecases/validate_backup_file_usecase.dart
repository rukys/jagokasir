// lib/features/backup/domain/usecases/validate_backup_file_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/backup_repository.dart';

class ValidateBackupFileUsecase {
  final BackupRepository _repository;
  const ValidateBackupFileUsecase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String filePath) async {
    if (filePath.isEmpty) {
      return left(const ValidationFailure('Path file backup tidak boleh kosong'));
    }
    return _repository.validateBackupFile(filePath);
  }
}
