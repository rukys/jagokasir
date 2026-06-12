// lib/features/printer/data/datasources/printer_local_datasource.dart

import '../../../../core/database/database_helper.dart';
import '../models/printer_model.dart';

class PrinterLocalDatasource {
  const PrinterLocalDatasource();

  Future<List<PrinterModel>> getAllPrinters() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query('printers', orderBy: 'created_at DESC');
    return results.map((map) => PrinterModel.fromMap(map)).toList();
  }

  Future<void> addPrinter(PrinterModel printer) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('printers', printer.toMap());
  }

  Future<void> updatePrinter(PrinterModel printer) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'printers',
      printer.toMap(),
      where: 'id = ?',
      whereArgs: [printer.id],
    );
  }

  Future<void> deletePrinter(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'printers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setDefaultPrinter(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      // Unset all printers as default
      await txn.update(
        'printers',
        {'is_default': 0},
      );
      // Set the chosen printer as default
      await txn.update(
        'printers',
        {'is_default': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
