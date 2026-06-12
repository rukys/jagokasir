import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

/// Hasil import CSV produk.
class ImportResult {
  final int success;
  final int skipped;
  final List<String> errors;

  const ImportResult({
    required this.success,
    required this.skipped,
    required this.errors,
  });

  @override
  String toString() =>
      'ImportResult(success: $success, skipped: $skipped, errors: ${errors.length})';
}

/// Abstract repository produk — diimplementasikan di data layer.
abstract interface class ProductRepository {
  /// Semua produk (is_deleted = 0), terurut nama ASC, JOIN kategori.
  Future<Either<Failure, List<ProductEntity>>> getAll();

  /// Produk aktif saja (is_deleted = 0, is_active = 1) — untuk layar kasir.
  Future<Either<Failure, List<ProductEntity>>> getActive();

  Future<Either<Failure, ProductEntity>> getById(String id);

  /// Cari berdasarkan nama / SKU / barcode (LIKE).
  Future<Either<Failure, List<ProductEntity>>> search({
    required String query,
    String? categoryId,
  });

  Future<Either<Failure, ProductEntity>> create(ProductEntity product);

  Future<Either<Failure, ProductEntity>> update(ProductEntity product);

  Future<Either<Failure, ProductEntity>> toggleActive(String id);

  Future<Either<Failure, Unit>> softDelete(String id);

  /// Return true jika SKU sudah dipakai produk lain.
  /// [excludeId] untuk exclude produk yang sedang di-edit.
  Future<Either<Failure, bool>> checkSkuExists(String sku, {String excludeId});

  /// Return true jika barcode sudah dipakai produk lain.
  Future<Either<Failure, bool>> checkBarcodeExists(
    String barcode, {
    String excludeId,
  });

  /// Import produk dari konten CSV (string).
  Future<Either<Failure, ImportResult>> importCsv(String csvContent);

  /// Export semua produk aktif ke string CSV.
  Future<Either<Failure, String>> exportCsv();
}
