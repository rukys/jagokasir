// lib/features/printer/data/datasources/store_config_datasource.dart

import '../../../../core/database/database_helper.dart';
import '../models/store_config_model.dart';

class StoreConfigDatasource {
  const StoreConfigDatasource();

  Future<StoreConfigModel> getStoreConfig() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'store_config',
      where: 'id = ?',
      whereArgs: ['store-config'],
      limit: 1,
    );

    if (results.isEmpty) {
      // Fallback if seeded data is missing (should not happen as it is seeded in MigrationV1)
      final defaultModel = StoreConfigModel(
        id: 'store-config',
        storeName: 'Toko Saya',
        autoPrint: true,
        updatedAt: DateTime.now(),
      );
      await db.insert('store_config', defaultModel.toMap());
      return defaultModel;
    }

    return StoreConfigModel.fromMap(results.first);
  }

  Future<void> updateStoreConfig(StoreConfigModel config) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'store_config',
      config.toMap(),
      where: 'id = ?',
      whereArgs: ['store-config'],
    );
  }
}
