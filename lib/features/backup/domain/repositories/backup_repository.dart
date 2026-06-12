// lib/features/backup/domain/repositories/backup_repository.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/backup_history_entity.dart';

abstract class BackupRepository {
  Future<Either<Failure, List<BackupHistoryEntity>>> getHistory();
  Future<Either<Failure, BackupHistoryEntity>> createBackup({required bool isAutoBackup});
  Future<Either<Failure, Unit>> deleteBackup(String id);
  Future<Either<Failure, Unit>> restoreBackup(String filePath);
  Future<Either<Failure, Unit>> shareBackup(String filePath);
  Future<Either<Failure, Map<String, dynamic>>> validateBackupFile(String filePath);
}
