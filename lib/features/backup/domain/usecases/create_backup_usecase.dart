// lib/features/backup/domain/usecases/create_backup_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/backup_history_entity.dart';
import '../repositories/backup_repository.dart';

class CreateBackupUsecase {
  final BackupRepository _repository;
  const CreateBackupUsecase(this._repository);

  Future<Either<Failure, BackupHistoryEntity>> call({bool isAutoBackup = false}) async {
    return _repository.createBackup(isAutoBackup: isAutoBackup);
  }
}
