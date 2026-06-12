// lib/features/stock/presentation/providers/stock_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/stock_local_datasource.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../domain/entities/stock_entity.dart';
import '../../domain/entities/stock_ledger_entity.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/usecases/adjust_stock_usecase.dart';
import '../../domain/usecases/get_all_stocks_usecase.dart';
import '../../domain/usecases/get_low_stock_products_usecase.dart';
import '../../domain/usecases/get_stock_by_product_usecase.dart';
import '../../domain/usecases/get_stock_ledger_usecase.dart';
import '../../domain/usecases/update_stock_settings_usecase.dart';

part 'stock_provider.g.dart';

// ── Dependency Providers ────────────────────────────────────────────────────

@riverpod
StockLocalDatasource stockLocalDatasource(Ref ref) =>
    const StockLocalDatasource();

@riverpod
StockRepository stockRepository(Ref ref) =>
    StockRepositoryImpl(ref.watch(stockLocalDatasourceProvider));

@riverpod
GetAllStocksUsecase getAllStocksUsecase(Ref ref) =>
    GetAllStocksUsecase(ref.watch(stockRepositoryProvider));

@riverpod
GetStockByProductUsecase getStockByProductUsecase(Ref ref) =>
    GetStockByProductUsecase(ref.watch(stockRepositoryProvider));

@riverpod
AdjustStockUsecase adjustStockUsecase(Ref ref) =>
    AdjustStockUsecase(ref.watch(stockRepositoryProvider));

@riverpod
GetStockLedgerUsecase getStockLedgerUsecase(Ref ref) =>
    GetStockLedgerUsecase(ref.watch(stockRepositoryProvider));

@riverpod
GetLowStockProductsUsecase getLowStockProductsUsecase(Ref ref) =>
    GetLowStockProductsUsecase(ref.watch(stockRepositoryProvider));

@riverpod
UpdateStockSettingsUsecase updateStockSettingsUsecase(Ref ref) =>
    UpdateStockSettingsUsecase(ref.watch(stockRepositoryProvider));

// ── Data Providers ──────────────────────────────────────────────────────────

/// Semua stok produk — reload saat ada invalidation.
@riverpod
Future<List<StockEntity>> stockList(Ref ref) async {
  final usecase = ref.watch(getAllStocksUsecaseProvider);
  final result = await usecase();
  return result.fold((f) => throw f, (s) => s);
}

/// Stok satu produk berdasarkan productId.
@riverpod
Future<StockEntity> stockByProduct(Ref ref, String productId) async {
  final usecase = ref.watch(getStockByProductUsecaseProvider);
  final result = await usecase(productId);
  return result.fold((f) => throw f, (s) => s);
}

/// Produk dengan stok rendah.
@riverpod
Future<List<StockEntity>> lowStockList(Ref ref) async {
  final usecase = ref.watch(getLowStockProductsUsecaseProvider);
  final result = await usecase();
  return result.fold((f) => throw f, (s) => s);
}

/// Jumlah produk stok rendah — untuk badge di navigasi.
@riverpod
Future<int> lowStockCount(Ref ref) async {
  final list = await ref.watch(lowStockListProvider.future);
  return list.length;
}

/// Riwayat mutasi stok satu produk.
@riverpod
Future<List<StockLedgerEntity>> stockLedger(
  Ref ref,
  String productId,
) async {
  final usecase = ref.watch(getStockLedgerUsecaseProvider);
  final result = await usecase(productId);
  return result.fold((f) => throw f, (s) => s);
}

// ── Stock Adjustment Notifier ────────────────────────────────────────────────

@riverpod
class StockAdjustmentNotifier extends _$StockAdjustmentNotifier {
  @override
  AsyncValue<StockEntity?> build() => const AsyncData(null);

  Future<bool> adjust({
    required String productId,
    required double changeAmount,
    required String reason,
    String? note,
    String? staffId,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(adjustStockUsecaseProvider);
    final result = await usecase(
      productId: productId,
      changeAmount: changeAmount,
      reason: reason,
      note: note,
      staffId: staffId,
    );
    return result.fold(
      (f) {
        state = AsyncError(f, StackTrace.current);
        return false;
      },
      (stock) {
        state = AsyncData(stock);
        // Invalidate semua provider yang bergantung pada stok
        ref.invalidate(stockListProvider);
        ref.invalidate(lowStockListProvider);
        ref.invalidate(lowStockCountProvider);
        ref.invalidate(stockByProductProvider(productId));
        ref.invalidate(stockLedgerProvider(productId));
        return true;
      },
    );
  }

  void reset() => state = const AsyncData(null);

  String? get errorMessage {
    final s = state;
    if (s is AsyncError) {
      final err = s.error;
      if (err is Failure) return err.message;
      return err.toString();
    }
    return null;
  }
}

// ── Stock Settings Notifier ─────────────────────────────────────────────────

@riverpod
class StockSettingsNotifier extends _$StockSettingsNotifier {
  @override
  AsyncValue<StockEntity?> build() => const AsyncData(null);

  Future<bool> updateSettings({
    required String productId,
    required double minimumStock,
    required bool trackStock,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(updateStockSettingsUsecaseProvider);
    final result = await usecase(
      productId: productId,
      minimumStock: minimumStock,
      trackStock: trackStock,
    );
    return result.fold(
      (f) {
        state = AsyncError(f, StackTrace.current);
        return false;
      },
      (stock) {
        state = AsyncData(stock);
        ref.invalidate(stockListProvider);
        ref.invalidate(lowStockListProvider);
        ref.invalidate(lowStockCountProvider);
        ref.invalidate(stockByProductProvider(productId));
        return true;
      },
    );
  }

  void reset() => state = const AsyncData(null);

  String? get errorMessage {
    final s = state;
    if (s is AsyncError) {
      final err = s.error;
      if (err is Failure) return err.message;
      return err.toString();
    }
    return null;
  }
}
