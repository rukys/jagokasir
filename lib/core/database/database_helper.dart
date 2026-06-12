import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_migrations.dart';

/// Singleton akses SQLite database.
/// Selalu gunakan: `final db = await DatabaseHelper.instance.database;`
///
/// Konfigurasi:
/// - PRAGMA foreign_keys = ON
/// - PRAGMA journal_mode = WAL
/// - Version: [DatabaseMigrations.currentVersion]
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  /// Nama file database SQLite.
  static const String _dbName = 'pos_kasir.db';

  /// Kembalikan instance database. Buka jika belum ada.
  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: DatabaseMigrations.currentVersion,
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
      onOpen: _onOpen,
    );
  }

  /// Aktifkan foreign keys dan WAL mode setiap kali DB dibuka.
  Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    try {
      await db.execute('PRAGMA journal_mode = WAL');
    } catch (_) {
      // Ignore "not an error" DatabaseException on iOS/Darwin sqflite
    }
  }

  /// Tutup koneksi database (dipanggil saat app dispose).
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Reset instance (untuk keperluan testing).
  Future<void> resetForTesting() async {
    await close();
  }
}
