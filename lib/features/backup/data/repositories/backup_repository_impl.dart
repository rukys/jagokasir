// lib/features/backup/data/repositories/backup_repository_impl.dart

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/checksum_util.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/backup_history_entity.dart';
import '../../domain/repositories/backup_repository.dart';
import '../datasources/backup_local_datasource.dart';
import '../models/backup_history_model.dart';

class BackupRepositoryImpl implements BackupRepository {
  final BackupLocalDatasource _datasource;
  const BackupRepositoryImpl(this._datasource);

  Future<String> _getBackupDirectory() async {
    final hasPermission = await _requestPermissions();
    if (Platform.isAndroid && hasPermission) {
      final dir = Directory('/storage/emulated/0/Documents/JagoKasir/Backup');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir.path;
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDocDir.path}/Backup');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir.path;
    }
  }

  Future<bool> _requestPermissions() async {
    if (!Platform.isAndroid) return true;
    
    // Check permission status
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }
    
    // Request permission (Manage External Storage for Android 11+)
    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) {
      return true;
    }

    // Fallback storage permission for Android < 11
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  @override
  Future<Either<Failure, List<BackupHistoryEntity>>> getHistory() async {
    try {
      final list = await _datasource.getAll();
      return right(list);
    } catch (e) {
      return left(DbFailure('Gagal mengambil riwayat backup: $e'));
    }
  }

  @override
  Future<Either<Failure, BackupHistoryEntity>> createBackup({required bool isAutoBackup}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // 1. Flush WAL & checkpoint
      await db.execute('PRAGMA wal_checkpoint(FULL)');

      // 2. Get database path and copy to a temporary location
      final dbPath = db.path;
      final tempDir = await getTemporaryDirectory();
      final tempDbFile = File(p.join(tempDir.path, 'pos_kasir.db'));
      if (tempDbFile.existsSync()) {
        tempDbFile.deleteSync();
      }
      await File(dbPath).copy(tempDbFile.path);

      // 3. Compute database checksum
      final dbChecksum = await ChecksumUtil.computeFileChecksum(tempDbFile.path);

      // 4. Retrieve statistics for metadata
      final totalTransactions = await _datasource.getTotalTransactions();
      final totalProducts = await _datasource.getTotalProducts();
      final totalStaffs = await _datasource.getTotalStaffs();

      // 5. Create metadata JSON file
      final metadata = {
        'app_version': '1.0.0',
        'backup_schema_version': 1,
        'created_at': DateTime.now().toIso8601String(),
        'db_checksum': dbChecksum,
        'device_model': Platform.isAndroid ? 'Android Device' : 'iOS Device',
        'total_transactions': totalTransactions,
        'total_products': totalProducts,
        'total_staff': totalStaffs,
      };
      
      final tempMetadataFile = File(p.join(tempDir.path, 'backup_metadata.json'));
      await tempMetadataFile.writeAsString(json.encode(metadata));

      // 6. Gather product image assets and store logo
      final List<Map<String, dynamic>> productRows = await db.query(
        DbConstants.tProducts,
        columns: [DbConstants.colId, 'image_path'],
        where: '${DbConstants.colIsDeleted} = 0 AND image_path IS NOT NULL AND image_path != ""',
      );

      final List<Map<String, dynamic>> storeConfigRows = await db.query(
        DbConstants.tStoreConfig,
        columns: ['logo_path'],
        limit: 1,
      );

      // 7. Create ZIP archive
      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[-T:.]'), '').substring(0, 14);
      final fileName = 'pos_backup_$timestamp.zip';
      final backupDirPath = await _getBackupDirectory();
      final zipFilePath = p.join(backupDirPath, fileName);

      final tempDbPath = tempDbFile.path;
      final tempMetadataPath = tempMetadataFile.path;

      final List<Map<String, String>> imagesToAdd = [];
      for (final row in productRows) {
        final productId = row[DbConstants.colId] as String;
        final imagePath = row['image_path'] as String?;
        if (imagePath != null && imagePath.isNotEmpty) {
          final file = File(imagePath);
          if (file.existsSync()) {
            final ext = p.extension(imagePath);
            imagesToAdd.add({
              'path': imagePath,
              'archivePath': 'assets/products/$productId$ext',
            });
          }
        }
      }

      String? logoPathToAdd;
      String? logoExtension;
      if (storeConfigRows.isNotEmpty && storeConfigRows.first['logo_path'] != null) {
        final logoPath = storeConfigRows.first['logo_path'] as String;
        final file = File(logoPath);
        if (file.existsSync()) {
          logoPathToAdd = logoPath;
          logoExtension = p.extension(logoPath);
        }
      }

      // Run zipping in background isolate
      await Isolate.run(() {
        final encoder = ZipFileEncoder();
        encoder.create(zipFilePath);
        encoder.addFile(File(tempDbPath));
        encoder.addFile(File(tempMetadataPath));
        for (final img in imagesToAdd) {
          encoder.addFile(File(img['path']!), img['archivePath']!);
        }
        if (logoPathToAdd != null && logoExtension != null) {
          encoder.addFile(File(logoPathToAdd), 'assets/store_logo$logoExtension');
        }
        encoder.close();
      });

      // Clean up temporary files
      tempDbFile.deleteSync();
      tempMetadataFile.deleteSync();

      // 8. Record in backup_history table
      final fileSizeBytes = File(zipFilePath).lengthSync();
      final model = BackupHistoryModel(
        id: UuidGenerator.generate(),
        fileName: fileName,
        filePath: zipFilePath,
        fileSizeBytes: fileSizeBytes,
        appVersion: '1.0.0',
        backupSchemaVersion: 1,
        dbChecksum: dbChecksum,
        totalTransactions: totalTransactions,
        createdAt: DateTime.now(),
      );

      await _datasource.insert(model);

      // 9. Auto-cleanup oldest backups
      final prefs = await SharedPreferences.getInstance();
      final maxBackupCount = prefs.getInt('max_backup_count') ?? 5;
      final historyList = await _datasource.getAll();

      if (historyList.length > maxBackupCount) {
        final toDeleteList = historyList.sublist(maxBackupCount);
        for (final item in toDeleteList) {
          final file = File(item.filePath);
          if (file.existsSync()) {
            file.deleteSync();
          }
          await _datasource.delete(item.id);
        }
      }

      return right(model);
    } on FileSystemException catch (e) {
      return left(FileFailure('Storage tidak mencukupi atau masalah file system: ${e.message}'));
    } catch (e) {
      return left(UnknownFailure('Gagal membuat backup: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteBackup(String id) async {
    try {
      final model = await _datasource.getById(id);
      if (model != null) {
        final file = File(model.filePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
        await _datasource.delete(id);
      }
      return right(unit);
    } catch (e) {
      return left(DbFailure('Gagal menghapus berkas backup dari database: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> validateBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return left(const ValidationFailure('Berkas backup tidak ditemukan di path yang ditentukan'));
      }

      if (!filePath.endsWith('.zip')) {
        return left(const ValidationFailure('Format berkas harus berupa zip (.zip)'));
      }

      // Read ZIP metadata inside background isolate to prevent UI thread blocking
      final bytes = await file.readAsBytes();
      
      final Map<String, dynamic> metadataMap = await Isolate.run(() {
        final archive = ZipDecoder().decodeBytes(bytes);

        ArchiveFile? metadataFile;
        ArchiveFile? dbFile;

        for (final archFile in archive) {
          if (archFile.name == 'backup_metadata.json') {
            metadataFile = archFile;
          } else if (archFile.name == 'pos_kasir.db') {
            dbFile = archFile;
          }
        }

        if (metadataFile == null) {
          throw const FormatException('Berkas backup rusak atau tidak valid: metadata hilang');
        }

        if (dbFile == null) {
          throw const FormatException('Berkas backup rusak atau tidak valid: database SQLite hilang');
        }

        final metadataContent = utf8.decode(metadataFile.content as List<int>);
        final map = json.decode(metadataContent) as Map<String, dynamic>;

        if (!map.containsKey('app_version') ||
            !map.containsKey('backup_schema_version') ||
            !map.containsKey('db_checksum')) {
          throw const FormatException('Struktur metadata di dalam berkas backup tidak lengkap');
        }

        final schemaVersion = map['backup_schema_version'] as int;
        if (schemaVersion > 1) {
          throw const FormatException(
            'Berkas backup dibuat dengan versi database yang lebih baru. Update aplikasi terlebih dahulu.',
          );
        }

        final dbBytes = dbFile.content as List<int>;
        final computedChecksum = ChecksumUtil.computeBytesChecksum(dbBytes);
        final expectedChecksum = map['db_checksum'] as String;

        if (computedChecksum != expectedChecksum) {
          throw const FormatException('Integritas berkas database rusak (checksum mismatch)');
        }

        return map;
      });

      return right(metadataMap);
    } catch (e) {
      if (e is FormatException) {
        return left(ValidationFailure(e.message));
      }
      return left(FileFailure('Gagal melakukan validasi berkas backup: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> restoreBackup(String filePath) async {
    File? flagFile;
    String? safetyNetPath;
    
    try {
      // 1. Validate the backup file first
      final validationResult = await validateBackupFile(filePath);
      if (validationResult.isLeft()) {
        return left(validationResult.fold((f) => f, (_) => throw Exception()));
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      flagFile = File(p.join(appDocDir.path, 'restore_in_progress.flag'));

      // 2. Create safety-net backup of current active data
      final safetyNetResult = await createBackup(isAutoBackup: true);
      if (safetyNetResult.isLeft()) {
        return left(safetyNetResult.fold((f) => f, (_) => throw Exception()));
      }
      final safetyNetModel = safetyNetResult.getOrElse((_) => throw Exception());
      final safetyNetPathLoc = safetyNetModel.filePath;
      safetyNetPath = safetyNetPathLoc;

      // 3. Write flag file to indicate active restore process in case of force-close
      await flagFile.writeAsString(safetyNetPathLoc);

      // 4. Close database connection helper
      await DatabaseHelper.instance.close();

      // 5. Decode ZIP and extract database
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      final dbPath = p.join(await getDatabasesPath(), 'pos_kasir.db');
      final appDocPath = appDocDir.path;

      // Run decoding and asset extraction in background isolate
      final Map<String, String> idToNewPathMap = await Isolate.run(() {
        final archive = ZipDecoder().decodeBytes(bytes);

        ArchiveFile? dbArchiveFile;
        final List<ArchiveFile> productImages = [];
        ArchiveFile? logoImage;

        for (final archFile in archive) {
          if (archFile.name == 'pos_kasir.db') {
            dbArchiveFile = archFile;
          } else if (archFile.name.startsWith('assets/products/')) {
            productImages.add(archFile);
          } else if (archFile.name.startsWith('assets/store_logo')) {
            logoImage = archFile;
          }
        }

        if (dbArchiveFile == null) {
          throw const FormatException('Database SQLite tidak ditemukan di dalam berkas backup');
        }

        // Overwrite the database file
        final activeDbFile = File(dbPath);
        if (activeDbFile.existsSync()) {
          activeDbFile.deleteSync();
        }
        activeDbFile.writeAsBytesSync(dbArchiveFile.content as List<int>);

        // Copy assets from ZIP to local application storage
        final restoredImagesDir = Directory(p.join(appDocPath, 'restored_assets', 'products'));
        if (!restoredImagesDir.existsSync()) {
          restoredImagesDir.createSync(recursive: true);
        }

        final Map<String, String> pathsMap = {};

        for (final imgFile in productImages) {
          final filename = p.basename(imgFile.name);
          final productId = p.basenameWithoutExtension(imgFile.name);
          final targetImgFile = File(p.join(restoredImagesDir.path, filename));
          targetImgFile.writeAsBytesSync(imgFile.content as List<int>);
          pathsMap[productId] = targetImgFile.path;
        }

        if (logoImage != null) {
          final filename = p.basename(logoImage.name);
          final targetLogoFile = File(p.join(appDocPath, 'restored_assets', filename));
          final logoDir = targetLogoFile.parent;
          if (!logoDir.existsSync()) {
            logoDir.createSync(recursive: true);
          }
          targetLogoFile.writeAsBytesSync(logoImage.content as List<int>);
          pathsMap['__store_logo__'] = targetLogoFile.path;
        }

        return pathsMap;
      });

      // 7. Open database connection and translate stored paths
      final db = await DatabaseHelper.instance.database;

      // Update image paths for products
      for (final entry in idToNewPathMap.entries) {
        if (entry.key == '__store_logo__') {
          await db.update(
            DbConstants.tStoreConfig,
            {'logo_path': entry.value},
          );
        } else {
          await db.update(
            DbConstants.tProducts,
            {'image_path': entry.value},
            where: '${DbConstants.colId} = ?',
            whereArgs: [entry.key],
          );
        }
      }

      // 8. Delete the recovery flag file
      if (flagFile.existsSync()) {
        flagFile.deleteSync();
      }

      return right(unit);
    } catch (e) {
      // 9. RECOVERY FLOW: Restore the safety-net database if restore fails in-flight
      try {
        if (safetyNetPath != null && File(safetyNetPath).existsSync()) {
          await DatabaseHelper.instance.close();
          final safetyBytes = await File(safetyNetPath).readAsBytes();
          final safetyArchive = ZipDecoder().decodeBytes(safetyBytes);
          
          ArchiveFile? safetyDbArchive;
          for (final archFile in safetyArchive) {
            if (archFile.name == 'pos_kasir.db') {
              safetyDbArchive = archFile;
              break;
            }
          }
          
          if (safetyDbArchive != null) {
            final dbPath = p.join(await getDatabasesPath(), 'pos_kasir.db');
            final activeDbFile = File(dbPath);
            if (activeDbFile.existsSync()) {
              activeDbFile.deleteSync();
            }
            await activeDbFile.writeAsBytes(safetyDbArchive.content as List<int>);
          }
        }
      } catch (_) {
        // Suppress nested recovery errors to throw the primary failure
      }

      if (flagFile != null && flagFile.existsSync()) {
        flagFile.deleteSync();
      }

      return left(FileFailure('Pemulihan gagal: $e. Data dipulihkan ke safety-net.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> shareBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return left(const NotFoundFailure('Berkas backup tidak ditemukan'));
      }
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: p.basename(filePath),
      );
      return right(unit);
    } catch (e) {
      return left(FileFailure('Gagal membagikan berkas backup: $e'));
    }
  }
}
