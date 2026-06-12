// lib/features/tax_discount/presentation/providers/tax_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/tax_local_datasource.dart';
import '../../data/repositories/tax_repository_impl.dart';
import '../../domain/entities/tax_config_entity.dart';
import '../../domain/repositories/tax_repository.dart';
import '../../domain/usecases/create_tax_config_usecase.dart';
import '../../domain/usecases/delete_tax_config_usecase.dart';
import '../../domain/usecases/get_active_tax_usecase.dart';
import '../../domain/usecases/get_all_tax_configs_usecase.dart';
import '../../domain/usecases/set_active_tax_usecase.dart';
import '../../domain/usecases/update_tax_config_usecase.dart';

part 'tax_provider.g.dart';

@riverpod
TaxLocalDatasource taxLocalDatasource(TaxLocalDatasourceRef ref) =>
    const TaxLocalDatasource();

@riverpod
TaxRepository taxRepository(TaxRepositoryRef ref) =>
    TaxRepositoryImpl(ref.watch(taxLocalDatasourceProvider));

@riverpod
GetAllTaxConfigsUsecase getAllTaxConfigsUsecase(GetAllTaxConfigsUsecaseRef ref) =>
    GetAllTaxConfigsUsecase(ref.watch(taxRepositoryProvider));

@riverpod
GetActiveTaxUsecase getActiveTaxUsecase(GetActiveTaxUsecaseRef ref) =>
    GetActiveTaxUsecase(ref.watch(taxRepositoryProvider));

@riverpod
CreateTaxConfigUsecase createTaxConfigUsecase(CreateTaxConfigUsecaseRef ref) =>
    CreateTaxConfigUsecase(ref.watch(taxRepositoryProvider));

@riverpod
UpdateTaxConfigUsecase updateTaxConfigUsecase(UpdateTaxConfigUsecaseRef ref) =>
    UpdateTaxConfigUsecase(ref.watch(taxRepositoryProvider));

@riverpod
SetActiveTaxUsecase setActiveTaxUsecase(SetActiveTaxUsecaseRef ref) =>
    SetActiveTaxUsecase(ref.watch(taxRepositoryProvider));

@riverpod
DeleteTaxConfigUsecase deleteTaxConfigUsecase(DeleteTaxConfigUsecaseRef ref) =>
    DeleteTaxConfigUsecase(ref.watch(taxRepositoryProvider));

@riverpod
Future<List<TaxConfigEntity>> taxList(TaxListRef ref) async {
  final usecase = ref.watch(getAllTaxConfigsUsecaseProvider);
  final result = await usecase();
  return result.fold(
    (failure) => throw failure,
    (taxConfigs) => taxConfigs,
  );
}

@riverpod
Future<TaxConfigEntity?> activeTax(ActiveTaxRef ref) async {
  final usecase = ref.watch(getActiveTaxUsecaseProvider);
  final result = await usecase();
  return result.fold(
    (failure) => throw failure,
    (activeTax) => activeTax,
  );
}

@riverpod
class TaxNotifier extends _$TaxNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> create({
    required String name,
    required double rate,
    required bool isInclusive,
  }) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(createTaxConfigUsecaseProvider);
    final result = await usecase(
      name: name,
      rate: rate,
      isInclusive: isInclusive,
    );
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (tax) {
        state = const AsyncValue.data(null);
        ref.invalidate(taxListProvider);
        return true;
      },
    );
  }

  Future<bool> update({
    required String id,
    required String name,
    required double rate,
    required bool isInclusive,
    required bool isActive,
    required DateTime createdAt,
  }) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(updateTaxConfigUsecaseProvider);
    final result = await usecase(
      id: id,
      name: name,
      rate: rate,
      isInclusive: isInclusive,
      isActive: isActive,
      createdAt: createdAt,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (tax) {
        state = const AsyncValue.data(null);
        ref.invalidate(taxListProvider);
        if (isActive) {
          ref.invalidate(activeTaxProvider);
        }
        return true;
      },
    );
  }

  Future<bool> setActive(String id) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(setActiveTaxUsecaseProvider);
    final result = await usecase(id);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(taxListProvider);
        ref.invalidate(activeTaxProvider);
        return true;
      },
    );
  }

  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(deleteTaxConfigUsecaseProvider);
    final result = await usecase(id);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(taxListProvider);
        ref.invalidate(activeTaxProvider);
        return true;
      },
    );
  }
}
