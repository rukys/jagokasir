import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDatasource _datasource;
  const ProductRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<ProductEntity>>> getAll() async {
    try {
      return right(await _datasource.getAll());
    } catch (e) {
      return left(DbFailure('Gagal memuat produk: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getActive() async {
    try {
      return right(await _datasource.getActive());
    } catch (e) {
      return left(DbFailure('Gagal memuat produk aktif: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getById(String id) async {
    try {
      return right(await _datasource.getById(id));
    } on NotFoundException catch (e) {
      return left(NotFoundFailure(e.message));
    } catch (e) {
      return left(DbFailure('Gagal memuat produk: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> search({
    required String query,
    String? categoryId,
  }) async {
    try {
      return right(
        await _datasource.search(query: query, categoryId: categoryId),
      );
    } catch (e) {
      return left(DbFailure('Gagal mencari produk: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> create(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      return right(await _datasource.insert(model));
    } on ConstraintException catch (e) {
      return left(ValidationFailure(e.message));
    } catch (e) {
      return left(DbFailure('Gagal menyimpan produk: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> update(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      return right(await _datasource.update(model));
    } on NotFoundException catch (e) {
      return left(NotFoundFailure(e.message));
    } catch (e) {
      return left(DbFailure('Gagal memperbarui produk: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> toggleActive(String id) async {
    try {
      return right(await _datasource.toggleActive(id));
    } on NotFoundException catch (e) {
      return left(NotFoundFailure(e.message));
    } catch (e) {
      return left(DbFailure('Gagal mengubah status produk: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> softDelete(String id) async {
    try {
      await _datasource.softDelete(id);
      return right(unit);
    } catch (e) {
      return left(DbFailure('Gagal menghapus produk: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkSkuExists(
    String sku, {
    String excludeId = '',
  }) async {
    try {
      return right(
        await _datasource.checkSkuExists(sku, excludeId: excludeId),
      );
    } catch (e) {
      return left(DbFailure('Gagal mengecek SKU: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkBarcodeExists(
    String barcode, {
    String excludeId = '',
  }) async {
    try {
      return right(
        await _datasource.checkBarcodeExists(barcode, excludeId: excludeId),
      );
    } catch (e) {
      return left(DbFailure('Gagal mengecek barcode: $e'));
    }
  }

  @override
  Future<Either<Failure, ImportResult>> importCsv(String csvContent) async {
    try {
      return right(await _datasource.importCsv(csvContent));
    } catch (e) {
      return left(DbFailure('Gagal import CSV: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> exportCsv() async {
    try {
      return right(await _datasource.exportCsv());
    } catch (e) {
      return left(DbFailure('Gagal export CSV: $e'));
    }
  }
}
