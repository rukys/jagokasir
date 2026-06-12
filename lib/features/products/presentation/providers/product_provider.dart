import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/export_products_csv_usecase.dart';
import '../../domain/usecases/get_all_products_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../domain/usecases/import_products_csv_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/soft_delete_product_usecase.dart';
import '../../domain/usecases/toggle_product_active_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';

part 'product_provider.g.dart';

// ── Dependency Providers ────────────────────────────────────────────────────

@riverpod
ProductLocalDatasource productLocalDatasource(Ref ref) {
  return const ProductLocalDatasource();
}

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepositoryImpl(ref.watch(productLocalDatasourceProvider));
}

@riverpod
GetAllProductsUsecase getAllProductsUsecase(Ref ref) =>
    GetAllProductsUsecase(ref.watch(productRepositoryProvider));

@riverpod
GetProductByIdUsecase getProductByIdUsecase(Ref ref) =>
    GetProductByIdUsecase(ref.watch(productRepositoryProvider));

@riverpod
CreateProductUsecase createProductUsecase(Ref ref) =>
    CreateProductUsecase(ref.watch(productRepositoryProvider));

@riverpod
UpdateProductUsecase updateProductUsecase(Ref ref) =>
    UpdateProductUsecase(ref.watch(productRepositoryProvider));

@riverpod
ToggleProductActiveUsecase toggleProductActiveUsecase(Ref ref) =>
    ToggleProductActiveUsecase(ref.watch(productRepositoryProvider));

@riverpod
SoftDeleteProductUsecase softDeleteProductUsecase(Ref ref) =>
    SoftDeleteProductUsecase(ref.watch(productRepositoryProvider));

@riverpod
SearchProductsUsecase searchProductsUsecase(Ref ref) =>
    SearchProductsUsecase(ref.watch(productRepositoryProvider));

@riverpod
ImportProductsCsvUsecase importProductsCsvUsecase(Ref ref) =>
    ImportProductsCsvUsecase(ref.watch(productRepositoryProvider));

@riverpod
ExportProductsCsvUsecase exportProductsCsvUsecase(Ref ref) =>
    ExportProductsCsvUsecase(ref.watch(productRepositoryProvider));

// ── Data Providers ──────────────────────────────────────────────────────────

/// Semua produk (is_deleted = 0).
@riverpod
Future<List<ProductEntity>> productList(Ref ref) async {
  final usecase = ref.watch(getAllProductsUsecaseProvider);
  final result = await usecase();
  return result.fold((f) => throw f, (p) => p);
}

/// Detail produk berdasarkan ID.
@riverpod
Future<ProductEntity> productDetail(Ref ref, String id) async {
  final usecase = ref.watch(getProductByIdUsecaseProvider);
  final result = await usecase(id);
  return result.fold((f) => throw f, (p) => p);
}

/// Produk terfilter berdasarkan search query + kategori.
/// Dipakai di product list screen dengan debounce.
@riverpod
Future<List<ProductEntity>> filteredProducts(
  Ref ref, {
  required String searchQuery,
  String? categoryId,
}) async {
  final usecase = ref.watch(searchProductsUsecaseProvider);
  final result = await usecase(
    query: searchQuery,
    categoryId: categoryId,
  );
  return result.fold((f) => throw f, (p) => p);
}

// ── Product Form State ──────────────────────────────────────────────────────

/// State form tambah/edit produk.
@riverpod
class ProductFormNotifier extends _$ProductFormNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> save({
    String? id, // null = create, non-null = update
    required String name,
    String? sku,
    required double sellingPrice,
    double? costPrice,
    required String categoryId,
    required String unit,
    String? barcode,
    String? imagePath,
  }) async {
    state = const AsyncLoading();

    if (id == null) {
      // Create
      final usecase = ref.read(createProductUsecaseProvider);
      final result = await usecase(
        name: name,
        sku: sku,
        sellingPrice: sellingPrice,
        costPrice: costPrice,
        categoryId: categoryId,
        unit: unit,
        barcode: barcode,
        imagePath: imagePath,
      );
      return result.fold(
        (f) {
          state = AsyncError(f, StackTrace.current);
          return false;
        },
        (_) {
          state = const AsyncData(null);
          ref.invalidate(productListProvider);
          ref.invalidate(filteredProductsProvider);
          return true;
        },
      );
    } else {
      // Update
      final usecase = ref.read(updateProductUsecaseProvider);
      final result = await usecase(
        id: id,
        name: name,
        sku: sku ?? '',
        sellingPrice: sellingPrice,
        costPrice: costPrice,
        categoryId: categoryId,
        unit: unit,
        barcode: barcode,
        imagePath: imagePath,
      );
      return result.fold(
        (f) {
          state = AsyncError(f, StackTrace.current);
          return false;
        },
        (_) {
          state = const AsyncData(null);
          ref.invalidate(productListProvider);
          ref.invalidate(filteredProductsProvider);
          ref.invalidate(productDetailProvider(id));
          return true;
        },
      );
    }
  }

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

// ── Product Actions Notifier ─────────────────────────────────────────────────

/// Toggle aktif/nonaktif dan soft delete produk.
@riverpod
class ProductActionNotifier extends _$ProductActionNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> toggleActive(String id) async {
    state = const AsyncLoading();
    final usecase = ref.read(toggleProductActiveUsecaseProvider);
    final result = await usecase(id);
    return result.fold(
      (f) {
        state = AsyncError(f, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(productListProvider);
        ref.invalidate(filteredProductsProvider);
        ref.invalidate(productDetailProvider(id));
        return true;
      },
    );
  }

  Future<bool> softDelete(String id) async {
    state = const AsyncLoading();
    final usecase = ref.read(softDeleteProductUsecaseProvider);
    final result = await usecase(id);
    return result.fold(
      (f) {
        state = AsyncError(f, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(productListProvider);
        ref.invalidate(filteredProductsProvider);
        return true;
      },
    );
  }

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

// ── Import / Export ──────────────────────────────────────────────────────────

@riverpod
class ImportCsvNotifier extends _$ImportCsvNotifier {
  @override
  AsyncValue<ImportResult?> build() => const AsyncData(null);

  Future<ImportResult?> importFromString(String csvContent) async {
    state = const AsyncLoading();
    final usecase = ref.read(importProductsCsvUsecaseProvider);
    final result = await usecase(csvContent);
    return result.fold(
      (f) {
        state = AsyncError(f, StackTrace.current);
        return null;
      },
      (importResult) {
        state = AsyncData(importResult);
        ref.invalidate(productListProvider);
        ref.invalidate(filteredProductsProvider);
        return importResult;
      },
    );
  }

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
