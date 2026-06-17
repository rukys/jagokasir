// lib/features/stock/data/repositories/stock_repository_impl.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/stock_entity.dart';
import '../../domain/entities/stock_ledger_entity.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_datasource.dart';

class StockRepositoryImpl implements StockRepository {
  final StockLocalDatasource _datasource;
  const StockRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<StockEntity>>> getAllStocks() async {
    try {
      return right(await _datasource.getAllStocks());
    } catch (error) {
      return left(DbFailure('Gagal memuat data stok: $error'));
    }
  }

  @override
  Future<Either<Failure, StockEntity>> getStockByProduct(
    String productId,
  ) async {
    try {
      return right(await _datasource.getStockByProduct(productId));
    } on NotFoundException catch (error) {
      return left(NotFoundFailure(error.message));
    } catch (error) {
      return left(DbFailure('Gagal memuat stok produk: $error'));
    }
  }

  @override
  Future<Either<Failure, StockEntity>> adjustStock({
    required String productId,
    required double changeAmount,
    required String reason,
    String? note,
    String? staffId,
  }) async {
    try {
      return right(
        await _datasource.adjustStock(
          productId: productId,
          changeAmount: changeAmount,
          reason: reason,
          note: note,
          staffId: staffId,
        ),
      );
    } on NotFoundException catch (error) {
      return left(NotFoundFailure(error.message));
    } catch (error) {
      return left(DbFailure('Gagal menyesuaikan stok: $error'));
    }
  }

  @override
  Future<Either<Failure, List<StockLedgerEntity>>> getStockLedger(
    String productId,
  ) async {
    try {
      return right(await _datasource.getStockLedger(productId));
    } catch (error) {
      return left(DbFailure('Gagal memuat riwayat stok: $error'));
    }
  }

  @override
  Future<Either<Failure, List<StockEntity>>> getLowStockProducts() async {
    try {
      return right(await _datasource.getLowStockProducts());
    } catch (error) {
      return left(DbFailure('Gagal memuat produk stok rendah: $error'));
    }
  }

  @override
  Future<Either<Failure, StockEntity>> updateStockSettings({
    required String productId,
    required double minimumStock,
    required bool trackStock,
  }) async {
    try {
      return right(
        await _datasource.updateStockSettings(
          productId: productId,
          minimumStock: minimumStock,
          trackStock: trackStock,
        ),
      );
    } on NotFoundException catch (error) {
      return left(NotFoundFailure(error.message));
    } catch (error) {
      return left(DbFailure('Gagal memperbarui setting stok: $error'));
    }
  }
}
