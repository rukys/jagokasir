// lib/features/printer/presentation/providers/store_config_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/store_config_datasource.dart';
import '../../data/repositories/store_config_repository_impl.dart';
import '../../domain/entities/store_config_entity.dart';
import '../../domain/repositories/store_config_repository.dart';
import '../../domain/usecases/get_store_config_usecase.dart';
import '../../domain/usecases/update_store_config_usecase.dart';

part 'store_config_provider.g.dart';

// ── Dependency Providers ────────────────────────────────────────────────────

@riverpod
StoreConfigDatasource storeConfigDatasource(Ref ref) {
  return const StoreConfigDatasource();
}

@riverpod
StoreConfigRepository storeConfigRepository(Ref ref) {
  return StoreConfigRepositoryImpl(ref.watch(storeConfigDatasourceProvider));
}

@riverpod
GetStoreConfigUsecase getStoreConfigUsecase(Ref ref) {
  return GetStoreConfigUsecase(ref.watch(storeConfigRepositoryProvider));
}

@riverpod
UpdateStoreConfigUsecase updateStoreConfigUsecase(Ref ref) {
  return UpdateStoreConfigUsecase(ref.watch(storeConfigRepositoryProvider));
}

// ── Data Provider ───────────────────────────────────────────────────────────

@riverpod
Future<StoreConfigEntity> storeConfig(Ref ref) async {
  final usecase = ref.watch(getStoreConfigUsecaseProvider);
  final result = await usecase();
  return result.fold(
    (failure) => throw failure,
    (config) => config,
  );
}

// ── Maintenance Notifier ────────────────────────────────────────────────────

@riverpod
class StoreConfigMaintenance extends _$StoreConfigMaintenance {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> updateConfig({
    required String storeName,
    String? storeAddress,
    String? storePhone,
    String? receiptFooter,
    String? logoPath,
    required bool autoPrint,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(updateStoreConfigUsecaseProvider);
    final currentConfig = await ref.read(storeConfigProvider.future);

    final updated = currentConfig.copyWith(
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      receiptFooter: receiptFooter,
      logoPath: logoPath,
      autoPrint: autoPrint,
      updatedAt: DateTime.now(),
    );

    final result = await usecase(updated);
    return result.fold(
      (failure) {
        state = AsyncError(Exception(failure.message), StackTrace.current);
        return false;
      },
      (_) {
        ref.invalidate(storeConfigProvider);
        state = const AsyncData(null);
        return true;
      },
    );
  }
}
