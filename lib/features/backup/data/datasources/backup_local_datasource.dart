// lib/features/backup/data/datasources/backup_local_datasource.dart

import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/backup_history_model.dart';

class BackupLocalDatasource {
  const BackupLocalDatasource();

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<List<BackupHistoryModel>> getAll() async {
    final db = await _db;
    final maps = await db.query(
      DbConstants.tBackupHistory,
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return maps.map((map) => BackupHistoryModel.fromMap(map)).toList();
  }

  Future<BackupHistoryModel?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(
      DbConstants.tBackupHistory,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return BackupHistoryModel.fromMap(maps.first);
  }

  Future<void> insert(BackupHistoryModel model) async {
    final db = await _db;
    await db.insert(
      DbConstants.tBackupHistory,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(
      DbConstants.tBackupHistory,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTotalTransactions() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${DbConstants.tTransactions}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalProducts() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.tProducts} WHERE ${DbConstants.colIsDeleted} = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalStaffs() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.tStaffs} WHERE ${DbConstants.colIsDeleted} = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<String?> getLastDataUpdateTime() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT MAX(last_update) AS max_time FROM (
        SELECT MAX(${DbConstants.colUpdatedAt}) AS last_update FROM ${DbConstants.tProducts} WHERE ${DbConstants.colIsDeleted} = 0
        UNION ALL
        SELECT MAX(${DbConstants.colCreatedAt}) AS last_update FROM ${DbConstants.tTransactions}
        UNION ALL
        SELECT MAX(${DbConstants.colVoidedAt}) AS last_update FROM ${DbConstants.tTransactions}
      )
    ''');
    if (result.isEmpty) return null;
    return result.first['max_time'] as String?;
  }
}
