import 'package:sqflite/sqflite.dart';

import 'migrations/migration_v1.dart';

/// Runner migration database.
/// Dipanggil dari [DatabaseHelper] saat `onCreate` dan `onUpgrade`.
class DatabaseMigrations {
  DatabaseMigrations._();

  /// Skema version saat ini — increment saat ada perubahan DDL.
  static const int currentVersion = 1;

  /// Dipanggil `onCreate` — DB baru, jalankan migration dari v0 → [currentVersion].
  static Future<void> onCreate(Database db, int version) async {
    final batch = db.batch();
    await MigrationV1.migrate(batch);
    await batch.commit(noResult: true);
  }

  /// Dipanggil `onUpgrade` — tambah case baru saat [currentVersion] naik.
  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    final batch = db.batch();

    if (oldVersion < 1) {
      await MigrationV1.migrate(batch);
    }
    // if (oldVersion < 2) { await MigrationV2.migrate(batch); }

    await batch.commit(noResult: true);
  }
}
