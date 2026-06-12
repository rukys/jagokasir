// lib/features/stock/domain/repositories/stock_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/stock_entity.dart';
import '../entities/stock_ledger_entity.dart';

/// Abstract interface untuk stock repository.
/// Implementasi ada di data layer.
abstract class StockRepository {
  /// Ambil semua stok produk (JOIN products, is_deleted = 0).
  Future<Either<Failure, List<StockEntity>>> getAllStocks();

  /// Ambil stok satu produk berdasarkan [productId].
  Future<Either<Failure, StockEntity>> getStockByProduct(String productId);

  /// Adjustment stok manual (RESTOCK atau ADJUSTMENT).
  /// Operasi atomic: update `stocks` + insert `stock_ledger` dalam satu transaksi.
  Future<Either<Failure, StockEntity>> adjustStock({
    required String productId,
    required double changeAmount,
    required String reason,
    String? note,
    String? staffId,
  });

  /// Ambil riwayat mutasi stok untuk satu produk.
  /// Diurutkan dari terbaru, LIMIT 100.
  Future<Either<Failure, List<StockLedgerEntity>>> getStockLedger(
    String productId,
  );

  /// Ambil semua produk yang stoknya rendah (track_stock=1, current<=minimum).
  Future<Either<Failure, List<StockEntity>>> getLowStockProducts();

  /// Update setting stok per produk: minimum_stock dan track_stock.
  Future<Either<Failure, StockEntity>> updateStockSettings({
    required String productId,
    required double minimumStock,
    required bool trackStock,
  });
}
