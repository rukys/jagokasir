// lib/features/backup/data/models/backup_history_model.dart

import '../../../../core/constants/db_constants.dart';
import '../../domain/entities/backup_history_entity.dart';

class BackupHistoryModel extends BackupHistoryEntity {
  const BackupHistoryModel({
    required super.id,
    required super.fileName,
    required super.filePath,
    required super.fileSizeBytes,
    required super.appVersion,
    required super.backupSchemaVersion,
    required super.dbChecksum,
    required super.totalTransactions,
    required super.createdAt,
  });

  factory BackupHistoryModel.fromMap(Map<String, dynamic> map) {
    return BackupHistoryModel(
      id: map[DbConstants.colId] as String,
      fileName: map[DbConstants.colFileName] as String,
      filePath: map[DbConstants.colFilePath] as String,
      fileSizeBytes: map[DbConstants.colFileSizeBytes] as int,
      appVersion: map[DbConstants.colAppVersion] as String,
      backupSchemaVersion: map[DbConstants.colBackupSchemaVer] as int,
      dbChecksum: map[DbConstants.colDbChecksum] as String,
      totalTransactions: map[DbConstants.colTotalTxn] as int,
      createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DbConstants.colId: id,
      DbConstants.colFileName: fileName,
      DbConstants.colFilePath: filePath,
      DbConstants.colFileSizeBytes: fileSizeBytes,
      DbConstants.colAppVersion: appVersion,
      DbConstants.colBackupSchemaVer: backupSchemaVersion,
      DbConstants.colDbChecksum: dbChecksum,
      DbConstants.colTotalTxn: totalTransactions,
      DbConstants.colCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory BackupHistoryModel.fromEntity(BackupHistoryEntity entity) {
    return BackupHistoryModel(
      id: entity.id,
      fileName: entity.fileName,
      filePath: entity.filePath,
      fileSizeBytes: entity.fileSizeBytes,
      appVersion: entity.appVersion,
      backupSchemaVersion: entity.backupSchemaVersion,
      dbChecksum: entity.dbChecksum,
      totalTransactions: entity.totalTransactions,
      createdAt: entity.createdAt,
    );
  }
}
