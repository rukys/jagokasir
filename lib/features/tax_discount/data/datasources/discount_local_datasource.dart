// lib/features/tax_discount/data/datasources/discount_local_datasource.dart

import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/discount_preset_model.dart';

class DiscountLocalDatasource {
  const DiscountLocalDatasource();

  Future<List<DiscountPresetModel>> getAllDiscountPresets() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      DbConstants.tDiscountPresets,
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return maps.map((map) => DiscountPresetModel.fromMap(map)).toList();
  }

  Future<List<DiscountPresetModel>> getActiveDiscountPresets() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      DbConstants.tDiscountPresets,
      where: '${DbConstants.colIsActive} = 1',
      orderBy: '${DbConstants.colName} ASC',
    );
    return maps.map((map) => DiscountPresetModel.fromMap(map)).toList();
  }

  Future<DiscountPresetModel> createDiscountPreset(DiscountPresetModel discount) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      DbConstants.tDiscountPresets,
      discount.toMap(),
    );
    return discount;
  }

  Future<DiscountPresetModel> updateDiscountPreset(DiscountPresetModel discount) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      DbConstants.tDiscountPresets,
      discount.toMap(),
      where: '${DbConstants.colId} = ?',
      whereArgs: [discount.id],
    );
    return discount;
  }

  Future<DiscountPresetModel> toggleDiscountPreset(String id, bool active) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      DbConstants.tDiscountPresets,
      {DbConstants.colIsActive: active ? 1 : 0},
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
    final maps = await db.query(
      DbConstants.tDiscountPresets,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return DiscountPresetModel.fromMap(maps.first);
  }

  Future<bool> deleteDiscountPreset(String id) async {
    final db = await DatabaseHelper.instance.database;
    final count = await db.delete(
      DbConstants.tDiscountPresets,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
    return count > 0;
  }
}
