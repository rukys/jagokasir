// lib/features/auth/data/datasources/staff_local_datasource.dart

import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/staff_model.dart';

class StaffLocalDatasource {
  const StaffLocalDatasource();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<bool> checkOnboarding() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DbConstants.tStaffs} '
      'WHERE ${DbConstants.colRole} = "OWNER" AND ${DbConstants.colIsActive} = 1',
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  Future<List<StaffModel>> getAllStaffs() async {
    final db = await _db;
    final rows = await db.query(
      DbConstants.tStaffs,
      orderBy: '${DbConstants.colName} ASC',
    );
    return rows.map(StaffModel.fromMap).toList();
  }

  Future<StaffModel?> getStaffById(String id) async {
    final db = await _db;
    final rows = await db.query(
      DbConstants.tStaffs,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StaffModel.fromMap(rows.first);
  }

  Future<void> createStaff(StaffModel model, String pinHash) async {
    final db = await _db;
    final data = model.toMap();
    data['pin_hash'] = pinHash;
    await db.insert(DbConstants.tStaffs, data);
  }

  Future<void> updateStaff(StaffModel model) async {
    final db = await _db;
    await db.update(
      DbConstants.tStaffs,
      {
        'name': model.name,
        'role': model.role.toDbValue(),
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> toggleStaffActive(String id, int active) async {
    final db = await _db;
    await db.update(
      DbConstants.tStaffs,
      {
        'is_active': active,
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> resetStaffPin(String id, String pinHash) async {
    final db = await _db;
    await db.update(
      DbConstants.tStaffs,
      {
        'pin_hash': pinHash,
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<String?> getPinHash(String id) async {
    final db = await _db;
    final rows = await db.query(
      DbConstants.tStaffs,
      columns: ['pin_hash'],
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['pin_hash'] as String?;
  }

  Future<void> updateLastLogin(String id, String lastLoginAt) async {
    final db = await _db;
    await db.update(
      DbConstants.tStaffs,
      {
        'last_login_at': lastLoginAt,
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> getActiveOwnerCount() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DbConstants.tStaffs} '
      'WHERE ${DbConstants.colRole} = "OWNER" AND ${DbConstants.colIsActive} = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
