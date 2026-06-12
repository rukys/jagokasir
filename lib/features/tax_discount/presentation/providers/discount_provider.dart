// lib/features/tax_discount/presentation/providers/discount_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/discount_local_datasource.dart';
import '../../data/repositories/discount_repository_impl.dart';
import '../../domain/entities/discount_preset_entity.dart';
import '../../domain/repositories/discount_repository.dart';
import '../../domain/usecases/create_discount_preset_usecase.dart';
import '../../domain/usecases/delete_discount_preset_usecase.dart';
import '../../domain/usecases/get_active_discount_presets_usecase.dart';
import '../../domain/usecases/get_all_discount_presets_usecase.dart';
import '../../domain/usecases/toggle_discount_preset_usecase.dart';
import '../../domain/usecases/update_discount_preset_usecase.dart';

part 'discount_provider.g.dart';

@riverpod
DiscountLocalDatasource discountLocalDatasource(DiscountLocalDatasourceRef ref) =>
    const DiscountLocalDatasource();

@riverpod
DiscountRepository discountRepository(DiscountRepositoryRef ref) =>
    DiscountRepositoryImpl(ref.watch(discountLocalDatasourceProvider));

@riverpod
GetAllDiscountPresetsUsecase getAllDiscountPresetsUsecase(GetAllDiscountPresetsUsecaseRef ref) =>
    GetAllDiscountPresetsUsecase(ref.watch(discountRepositoryProvider));

@riverpod
GetActiveDiscountPresetsUsecase getActiveDiscountPresetsUsecase(GetActiveDiscountPresetsUsecaseRef ref) =>
    GetActiveDiscountPresetsUsecase(ref.watch(discountRepositoryProvider));

@riverpod
CreateDiscountPresetUsecase createDiscountPresetUsecase(CreateDiscountPresetUsecaseRef ref) =>
    CreateDiscountPresetUsecase(ref.watch(discountRepositoryProvider));

@riverpod
UpdateDiscountPresetUsecase updateDiscountPresetUsecase(UpdateDiscountPresetUsecaseRef ref) =>
    UpdateDiscountPresetUsecase(ref.watch(discountRepositoryProvider));

@riverpod
ToggleDiscountPresetUsecase toggleDiscountPresetUsecase(ToggleDiscountPresetUsecaseRef ref) =>
    ToggleDiscountPresetUsecase(ref.watch(discountRepositoryProvider));

@riverpod
DeleteDiscountPresetUsecase deleteDiscountPresetUsecase(DeleteDiscountPresetUsecaseRef ref) =>
    DeleteDiscountPresetUsecase(ref.watch(discountRepositoryProvider));

@riverpod
Future<List<DiscountPresetEntity>> discountList(DiscountListRef ref) async {
  final usecase = ref.watch(getAllDiscountPresetsUsecaseProvider);
  final result = await usecase();
  return result.fold(
    (failure) => throw failure,
    (discounts) => discounts,
  );
}

@riverpod
Future<List<DiscountPresetEntity>> activeDiscountPresets(ActiveDiscountPresetsRef ref) async {
  final usecase = ref.watch(getActiveDiscountPresetsUsecaseProvider);
  final result = await usecase();
  return result.fold(
    (failure) => throw failure,
    (discounts) => discounts,
  );
}

@riverpod
class DiscountNotifier extends _$DiscountNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> create({
    required String name,
    required DiscountType type,
    required double value,
  }) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(createDiscountPresetUsecaseProvider);
    final result = await usecase(
      name: name,
      type: type,
      value: value,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (discount) {
        state = const AsyncValue.data(null);
        ref.invalidate(discountListProvider);
        if (discount.isActive) {
          ref.invalidate(activeDiscountPresetsProvider);
        }
        return true;
      },
    );
  }

  Future<bool> update({
    required String id,
    required String name,
    required DiscountType type,
    required double value,
    required bool isActive,
    required DateTime createdAt,
  }) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(updateDiscountPresetUsecaseProvider);
    final result = await usecase(
      id: id,
      name: name,
      type: type,
      value: value,
      isActive: isActive,
      createdAt: createdAt,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (discount) {
        state = const AsyncValue.data(null);
        ref.invalidate(discountListProvider);
        ref.invalidate(activeDiscountPresetsProvider);
        return true;
      },
    );
  }

  Future<bool> toggleActive({
    required String id,
    required bool isActive,
  }) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(toggleDiscountPresetUsecaseProvider);
    final result = await usecase(
      id: id,
      isActive: isActive,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(discountListProvider);
        ref.invalidate(activeDiscountPresetsProvider);
        return true;
      },
    );
  }

  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(deleteDiscountPresetUsecaseProvider);
    final result = await usecase(id);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(discountListProvider);
        ref.invalidate(activeDiscountPresetsProvider);
        return true;
      },
    );
  }
}
