// lib/features/backup/domain/entities/backup_history_entity.dart

class BackupHistoryEntity {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSizeBytes;
  final String appVersion;
  final int backupSchemaVersion;
  final String dbChecksum;
  final int totalTransactions;
  final DateTime createdAt;

  const BackupHistoryEntity({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSizeBytes,
    required this.appVersion,
    required this.backupSchemaVersion,
    required this.dbChecksum,
    required this.totalTransactions,
    required this.createdAt,
  });

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    }
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
