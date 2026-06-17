// test/features/backup/backup_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos_kasir/core/error/failures.dart';
import 'package:pos_kasir/features/backup/domain/entities/backup_history_entity.dart';
import 'package:pos_kasir/features/backup/domain/repositories/backup_repository.dart';
import 'package:pos_kasir/features/backup/domain/usecases/create_backup_usecase.dart';
import 'package:pos_kasir/features/backup/domain/usecases/delete_backup_usecase.dart';
import 'package:pos_kasir/features/backup/domain/usecases/get_backup_history_usecase.dart';
import 'package:pos_kasir/features/backup/domain/usecases/restore_backup_usecase.dart';
import 'package:pos_kasir/features/backup/domain/usecases/validate_backup_file_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeBackupRepository implements BackupRepository {
  final List<BackupHistoryEntity> backups = [];
  bool shouldFailRestore = false;
  bool shouldFailValidation = false;
  int _backupCounter = 0;

  @override
  Future<Either<Failure, List<BackupHistoryEntity>>> getHistory() async {
    return right(List.from(backups));
  }

  @override
  Future<Either<Failure, BackupHistoryEntity>> createBackup({required bool isAutoBackup}) async {
    _backupCounter++;
    final newBackup = BackupHistoryEntity(
      id: 'backup-$_backupCounter',
      fileName: 'pos_backup_test_$_backupCounter.zip',
      filePath: '/virtual/path/pos_backup_test_$_backupCounter.zip',
      fileSizeBytes: 1024 * 100, // 100 KB
      appVersion: '1.0.0',
      backupSchemaVersion: 1,
      dbChecksum: 'fake-checksum-123',
      totalTransactions: 10,
      createdAt: DateTime.now(),
    );
    backups.insert(0, newBackup); // Newest first

    // Simulate auto-cleanup during create
    final prefs = await SharedPreferences.getInstance();
    final maxBackupCount = prefs.getInt('max_backup_count') ?? 5;
    if (backups.length > maxBackupCount) {
      backups.removeRange(maxBackupCount, backups.length);
    }

    return right(newBackup);
  }

  @override
  Future<Either<Failure, Unit>> deleteBackup(String id) async {
    backups.removeWhere((b) => b.id == id);
    return right(unit);
  }

  @override
  Future<Either<Failure, Unit>> restoreBackup(String filePath) async {
    if (shouldFailRestore) {
      return left(const FileFailure('Pemulihan gagal: file corrupt'));
    }
    return right(unit);
  }

  @override
  Future<Either<Failure, Unit>> shareBackup(String filePath) async {
    if (filePath.isEmpty) {
      return left(const NotFoundFailure('Berkas tidak ditemukan'));
    }
    return right(unit);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> validateBackupFile(String filePath) async {
    if (shouldFailValidation) {
      return left(const ValidationFailure('Integritas berkas database rusak (checksum mismatch)'));
    }
    if (filePath.isEmpty) {
      return left(const ValidationFailure('Berkas backup tidak ditemukan'));
    }
    return right({
      'app_version': '1.0.0',
      'backup_schema_version': 1,
      'created_at': DateTime.now().toIso8601String(),
      'db_checksum': 'fake-checksum-123',
      'total_transactions': 12,
      'total_products': 5,
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeBackupRepository backupRepository;

  setUp(() {
    backupRepository = FakeBackupRepository();
    SharedPreferences.setMockInitialValues({});
  });

  group('Backup & Restore Usecases & Logic', () {
    test('CreateBackupUsecase should create a backup and store it in list', () async {
      final usecase = CreateBackupUsecase(backupRepository);
      
      final res = await usecase(isAutoBackup: false);
      expect(res.isRight(), true);
      final model = res.getOrElse((_) => throw Exception());
      expect(model.fileName, contains('pos_backup_test_1.zip'));
      expect(model.totalTransactions, 10);
      expect(backupRepository.backups, hasLength(1));
    });

    test('GetBackupHistoryUsecase should return history ordered by newest', () async {
      final createUsecase = CreateBackupUsecase(backupRepository);
      final getUsecase = GetBackupHistoryUsecase(backupRepository);

      await createUsecase();
      await createUsecase();

      final res = await getUsecase();
      expect(res.isRight(), true);
      final list = res.getOrElse((_) => []);
      expect(list, hasLength(2));
      expect(list.first.fileName, contains('pos_backup_test_2.zip'));
      expect(list.last.fileName, contains('pos_backup_test_1.zip'));
    });

    test('DeleteBackupUsecase should remove backup from database/list', () async {
      final createUsecase = CreateBackupUsecase(backupRepository);
      final deleteUsecase = DeleteBackupUsecase(backupRepository);

      final res = await createUsecase();
      final backup = res.getOrElse((_) => throw Exception());
      expect(backupRepository.backups, hasLength(1));

      final delRes = await deleteUsecase(backup.id);
      expect(delRes.isRight(), true);
      expect(backupRepository.backups, isEmpty);
    });

    test('ValidateBackupFileUsecase should validate schema and compatibility', () async {
      final usecase = ValidateBackupFileUsecase(backupRepository);

      // 1. Success case
      final res = await usecase('/path/backup.zip');
      expect(res.isRight(), true);
      final metadata = res.getOrElse((_) => {});
      expect(metadata['app_version'], '1.0.0');
      expect(metadata['total_transactions'], 12);

      // 2. Failure case
      backupRepository.shouldFailValidation = true;
      final failRes = await usecase('/path/backup.zip');
      expect(failRes.isLeft(), true);
      failRes.fold(
        (f) => expect(f.message, contains('checksum mismatch')),
        (_) => fail('Should have failed'),
      );
    });

    test('RestoreBackupUsecase should succeed and trigger restoration flow', () async {
      final usecase = RestoreBackupUsecase(backupRepository);

      final res = await usecase('/path/backup.zip');
      expect(res.isRight(), true);

      // Empty path validation
      final emptyRes = await usecase('');
      expect(emptyRes.isLeft(), true);
    });

    test('Auto-cleanup removes old backups exceeding limit', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('max_backup_count', 3);

      final usecase = CreateBackupUsecase(backupRepository);
      
      // Create 5 backups
      await usecase();
      await usecase();
      await usecase();
      await usecase();
      await usecase();

      // Only newest 3 should remain
      expect(backupRepository.backups, hasLength(3));
      expect(backupRepository.backups.first.fileName, contains('pos_backup_test_5.zip'));
      expect(backupRepository.backups.last.fileName, contains('pos_backup_test_3.zip'));
    });
  });
}
