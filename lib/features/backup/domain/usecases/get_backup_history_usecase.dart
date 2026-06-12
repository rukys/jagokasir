// lib/features/backup/domain/usecases/get_backup_history_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/backup_history_entity.dart';
import '../repositories/backup_repository.dart';

class GetBackupHistoryUsecase {
  final BackupRepository _repository;
  const GetBackupHistoryUsecase(this._repository);

  Future<Either<Failure, List<BackupHistoryEntity>>> call() async {
    return _repository.getHistory();
  }
}
