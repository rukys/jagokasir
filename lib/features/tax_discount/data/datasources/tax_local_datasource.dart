// lib/features/tax_discount/data/datasources/tax_local_datasource.dart

import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/tax_config_model.dart';

class TaxLocalDatasource {
  const TaxLocalDatasource();

  Future<List<TaxConfigModel>> getAllTaxConfigs() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      DbConstants.tTaxConfig,
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return maps.map((map) => TaxConfigModel.fromMap(map)).toList();
  }

  Future<TaxConfigModel?> getActiveTax() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      DbConstants.tTaxConfig,
      where: '${DbConstants.colIsActive} = 1',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TaxConfigModel.fromMap(maps.first);
  }

  Future<TaxConfigModel> createTaxConfig(TaxConfigModel tax) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      DbConstants.tTaxConfig,
      tax.toMap(),
    );
    return tax;
  }

  Future<TaxConfigModel> updateTaxConfig(TaxConfigModel tax) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      DbConstants.tTaxConfig,
      tax.toMap(),
      where: '${DbConstants.colId} = ?',
      whereArgs: [tax.id],
    );
    return tax;
  }

  Future<bool> setActiveTax(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      // 1. Nonaktifkan semua pajak
      await txn.update(
        DbConstants.tTaxConfig,
        {DbConstants.colIsActive: 0},
      );
      // 2. Aktifkan pajak terpilih
      await txn.update(
        DbConstants.tTaxConfig,
        {DbConstants.colIsActive: 1},
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
    });
    return true;
  }

  Future<bool> deleteTaxConfig(String id) async {
    final db = await DatabaseHelper.instance.database;
    final count = await db.delete(
      DbConstants.tTaxConfig,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
    return count > 0;
  }
}
