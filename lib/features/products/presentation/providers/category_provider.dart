import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/get_all_categories_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';

part 'category_provider.g.dart';

// ── Dependency Providers ────────────────────────────────────────────────────

@riverpod
CategoryLocalDatasource categoryLocalDatasource(Ref ref) {
  return const CategoryLocalDatasource();
}

@riverpod
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepositoryImpl(ref.watch(categoryLocalDatasourceProvider));
}

@riverpod
GetAllCategoriesUsecase getAllCategoriesUsecase(Ref ref) {
  return GetAllCategoriesUsecase(ref.watch(categoryRepositoryProvider));
}

@riverpod
CreateCategoryUsecase createCategoryUsecase(Ref ref) {
  return CreateCategoryUsecase(ref.watch(categoryRepositoryProvider));
}

@riverpod
UpdateCategoryUsecase updateCategoryUsecase(Ref ref) {
  return UpdateCategoryUsecase(ref.watch(categoryRepositoryProvider));
}

@riverpod
DeleteCategoryUsecase deleteCategoryUsecase(Ref ref) {
  return DeleteCategoryUsecase(ref.watch(categoryRepositoryProvider));
}

// ── Data Providers ──────────────────────────────────────────────────────────

/// Daftar semua kategori (is_deleted = 0).
@riverpod
Future<List<CategoryEntity>> categoryList(Ref ref) async {
  final usecase = ref.watch(getAllCategoriesUsecaseProvider);
  final result = await usecase();
  return result.fold((failure) => throw failure, (categories) => categories);
}

// ── Notifier (CRUD) ─────────────────────────────────────────────────────────

/// State untuk operasi CRUD kategori.
@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create({required String name, String? colorHex}) async {
    state = const AsyncLoading();
    final usecase = ref.read(createCategoryUsecaseProvider);
    final result = await usecase(name: name, colorHex: colorHex);
    return result.fold(
      (f) {
        state = AsyncError(f, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(categoryListProvider);
        return true;
      },
    );
  }

  Future<bool> update({
    required String id,
    required String name,
    String? colorHex,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(updateCategoryUsecaseProvider);
    final result = await usecase(id: id, name: name, colorHex: colorHex);
    return result.fold(
      (f) {
        state = AsyncError(f, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(categoryListProvider);
        return true;
      },
    );
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    final usecase = ref.read(deleteCategoryUsecaseProvider);
    final result = await usecase(id);
    return result.fold(
      (f) {
        state = AsyncError(f, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(categoryListProvider);
        return true;
      },
    );
  }

  /// Ambil pesan error dari state.
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
