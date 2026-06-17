import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/db_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/sku_generator.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class CreateProductUsecase {
  final ProductRepository _repository;
  const CreateProductUsecase(this._repository);

  Future<Either<Failure, ProductEntity>> call({
    required String name,
    String? sku,
    required double sellingPrice,
    double? costPrice,
    required String categoryId,
    required String unit,
    String? barcode,
    String? imagePath,
  }) async {
    // Validasi nama
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return left(const ValidationFailure('Nama produk tidak boleh kosong'));
    }

    // Validasi harga jual
    if (sellingPrice < 0) {
      return left(const ValidationFailure('Harga jual tidak boleh negatif'));
    }

    // Validasi harga modal
    if (costPrice != null && costPrice < 0) {
      return left(const ValidationFailure('Harga modal tidak boleh negatif'));
    }

    // Validasi unit
    final trimmedUnit = unit.trim();
    if (trimmedUnit.isEmpty) {
      return left(const ValidationFailure('Satuan tidak boleh kosong'));
    }

    // Auto-generate SKU jika kosong
    final effectiveSku =
        (sku == null || sku.trim().isEmpty)
            ? SkuGenerator.generate(trimmedName)
            : sku.trim().toUpperCase();

    // Cek SKU unik
    final skuCheck = await _repository.checkSkuExists(
      effectiveSku,
      excludeId: '',
    );
    final skuExists = skuCheck.fold((_) => false, (skuExists) => skuExists);
    if (skuExists) {
      return left(
        ValidationFailure('SKU "$effectiveSku" sudah digunakan produk lain'),
      );
    }

    // Cek barcode unik (jika diisi)
    if (barcode != null && barcode.trim().isNotEmpty) {
      final bcCheck = await _repository.checkBarcodeExists(
        barcode.trim(),
        excludeId: '',
      );
      final bcExists = bcCheck.fold((_) => false, (barcodeExists) => barcodeExists);
      if (bcExists) {
        return left(
          ValidationFailure('Barcode "${barcode.trim()}" sudah digunakan produk lain'),
        );
      }
    }

    final now = DateTime.now();
    final product = ProductEntity(
      id: UuidGenerator.generate(),
      name: trimmedName,
      sku: effectiveSku,
      sellingPrice: sellingPrice,
      costPrice: costPrice,
      categoryId: categoryId.isEmpty ? DbConstants.defaultCategoryId : categoryId,
      unit: trimmedUnit,
      barcode: barcode?.trim().isEmpty == true ? null : barcode?.trim(),
      imagePath: imagePath,
      isActive: true,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    );
    return _repository.create(product);
  }
}
