// lib/features/stock/data/datasources/stock_local_datasource.dart

import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../models/stock_ledger_model.dart';
import '../models/stock_model.dart';

/// Datasource stok — akses langsung ke SQLite.
/// Semua kolom via [DbConstants] — tidak boleh hardcode string.
class StockLocalDatasource {
  const StockLocalDatasource();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  // ── JOIN query untuk stocks + data produk ──────────────────────────────────
  static const String _stockJoinQuery = '''
    SELECT
      s.${DbConstants.colId},
      s.${DbConstants.colProductId},
      s.${DbConstants.colCurrentStock},
      s.${DbConstants.colMinimumStock},
      s.${DbConstants.colTrackStock},
      p.${DbConstants.colName}           AS product_name,
      p.${DbConstants.colSku}            AS product_sku,
      p.${DbConstants.colUnit}           AS product_unit,
      p.${DbConstants.colImagePath}      AS product_image_path
    FROM ${DbConstants.tStocks} s
    JOIN ${DbConstants.tProducts} p
      ON s.${DbConstants.colProductId} = p.${DbConstants.colId}
  ''';

  // ── JOIN query untuk stock_ledger + nama staff ─────────────────────────────
  static const String _ledgerJoinQuery = '''
    SELECT
      sl.${DbConstants.colId},
      sl.${DbConstants.colProductId},
      sl.${DbConstants.colChangeAmount},
      sl.${DbConstants.colStockAfter},
      sl.${DbConstants.colReason},
      sl.${DbConstants.colReferenceId},
      sl.${DbConstants.colNote},
      sl.${DbConstants.colStaffId},
      sl.${DbConstants.colCreatedAt},
      st.${DbConstants.colName}          AS staff_name
    FROM ${DbConstants.tStockLedger} sl
    LEFT JOIN ${DbConstants.tStaffs} st
      ON sl.${DbConstants.colStaffId} = st.${DbConstants.colId}
  ''';

  // ── Queries ────────────────────────────────────────────────────────────────

  /// Semua stok produk yang belum dihapus, diurutkan nama produk A→Z.
  Future<List<StockModel>> getAllStocks() async {
    final db = await _db;
    final rows = await db.rawQuery(
      '$_stockJoinQuery WHERE p.${DbConstants.colIsDeleted} = 0'
      ' ORDER BY p.${DbConstants.colName} ASC',
    );
    return rows.map(StockModel.fromMap).toList();
  }

  /// Stok satu produk — throw [NotFoundException] jika belum ada record stok.
  Future<StockModel> getStockByProduct(String productId) async {
    final db = await _db;
    final rows = await db.rawQuery(
      '$_stockJoinQuery WHERE s.${DbConstants.colProductId} = ? LIMIT 1',
      [productId],
    );
    if (rows.isEmpty) {
      throw NotFoundException('Stok tidak ditemukan untuk produk: $productId');
    }
    return StockModel.fromMap(rows.first);
  }

  /// Adjustment stok: atomic update `stocks` + insert `stock_ledger`.
  Future<StockModel> adjustStock({
    required String productId,
    required double changeAmount,
    required String reason,
    String? note,
    String? staffId,
  }) async {
    final db = await _db;

    // Ambil stok saat ini — untuk hitung stock_after
    final current = await getStockByProduct(productId);
    final stockAfter = current.currentStock + changeAmount;

    await db.transaction((txn) async {
      // 1. Update current_stock di tabel stocks
      await txn.update(
        DbConstants.tStocks,
        {DbConstants.colCurrentStock: stockAfter},
        where: '${DbConstants.colProductId} = ?',
        whereArgs: [productId],
      );

      // 2. Append entry di stock_ledger (JANGAN update/delete ledger)
      await txn.insert(DbConstants.tStockLedger, {
        DbConstants.colId: UuidGenerator.generate(),
        DbConstants.colProductId: productId,
        DbConstants.colChangeAmount: changeAmount,
        DbConstants.colStockAfter: stockAfter,
        DbConstants.colReason: reason,
        DbConstants.colReferenceId: null,
        DbConstants.colNote: note,
        DbConstants.colStaffId: staffId,
        DbConstants.colCreatedAt: DateTime.now().toIso8601String(),
      });
    });

    // Kembalikan data stok terbaru setelah update
    return getStockByProduct(productId);
  }

  /// Riwayat mutasi stok untuk satu produk — terbaru dulu, max 100 entri.
  Future<List<StockLedgerModel>> getStockLedger(String productId) async {
    final db = await _db;
    final rows = await db.rawQuery(
      '$_ledgerJoinQuery WHERE sl.${DbConstants.colProductId} = ?'
      ' ORDER BY sl.${DbConstants.colCreatedAt} DESC LIMIT 100',
      [productId],
    );
    return rows.map(StockLedgerModel.fromMap).toList();
  }

  /// Produk dengan stok rendah:
  /// `track_stock = 1` AND `current_stock <= minimum_stock` AND produk aktif.
  Future<List<StockModel>> getLowStockProducts() async {
    final db = await _db;
    final rows = await db.rawQuery(
      '$_stockJoinQuery'
      ' WHERE s.${DbConstants.colTrackStock} = 1'
      '   AND s.${DbConstants.colCurrentStock} <= s.${DbConstants.colMinimumStock}'
      '   AND p.${DbConstants.colIsDeleted} = 0'
      '   AND p.${DbConstants.colIsActive} = 1'
      ' ORDER BY s.${DbConstants.colCurrentStock} ASC',
    );
    return rows.map(StockModel.fromMap).toList();
  }

  /// Update setting stok: minimum_stock dan track_stock per produk.
  Future<StockModel> updateStockSettings({
    required String productId,
    required double minimumStock,
    required bool trackStock,
  }) async {
    final db = await _db;
    final count = await db.update(
      DbConstants.tStocks,
      {
        DbConstants.colMinimumStock: minimumStock,
        DbConstants.colTrackStock: trackStock ? 1 : 0,
      },
      where: '${DbConstants.colProductId} = ?',
      whereArgs: [productId],
    );
    if (count == 0) {
      throw NotFoundException(
        'Record stok tidak ditemukan untuk produk: $productId',
      );
    }
    return getStockByProduct(productId);
  }
}
