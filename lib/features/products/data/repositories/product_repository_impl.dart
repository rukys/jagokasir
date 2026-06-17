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
    } catch (error) {
      return left(DbFailure('Gagal memuat produk: $error'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getActive() async {
    try {
      return right(await _datasource.getActive());
    } catch (error) {
      return left(DbFailure('Gagal memuat produk aktif: $error'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getById(String id) async {
    try {
      return right(await _datasource.getById(id));
    } on NotFoundException catch (error) {
      return left(NotFoundFailure(error.message));
    } catch (error) {
      return left(DbFailure('Gagal memuat produk: $error'));
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
    } catch (error) {
      return left(DbFailure('Gagal mencari produk: $error'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> create(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      return right(await _datasource.insert(model));
    } on ConstraintException catch (error) {
      return left(ValidationFailure(error.message));
    } catch (error) {
      return left(DbFailure('Gagal menyimpan produk: $error'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> update(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      return right(await _datasource.update(model));
    } on NotFoundException catch (error) {
      return left(NotFoundFailure(error.message));
    } catch (error) {
      return left(DbFailure('Gagal memperbarui produk: $error'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> toggleActive(String id) async {
    try {
      return right(await _datasource.toggleActive(id));
    } on NotFoundException catch (error) {
      return left(NotFoundFailure(error.message));
    } catch (error) {
      return left(DbFailure('Gagal mengubah status produk: $error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> softDelete(String id) async {
    try {
      await _datasource.softDelete(id);
      return right(unit);
    } catch (error) {
      return left(DbFailure('Gagal menghapus produk: $error'));
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
    } catch (error) {
      return left(DbFailure('Gagal mengecek SKU: $error'));
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
    } catch (error) {
      return left(DbFailure('Gagal mengecek barcode: $error'));
    }
  }

  @override
  Future<Either<Failure, ImportResult>> importCsv(String csvContent) async {
    try {
      return right(await _datasource.importCsv(csvContent));
    } catch (error) {
      return left(DbFailure('Gagal import CSV: $error'));
    }
  }

  @override
  Future<Either<Failure, String>> exportCsv() async {
    try {
      return right(await _datasource.exportCsv());
    } catch (error) {
      return left(DbFailure('Gagal export CSV: $error'));
    }
  }
}
