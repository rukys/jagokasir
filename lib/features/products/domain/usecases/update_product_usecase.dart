import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/db_constants.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class UpdateProductUsecase {
  final ProductRepository _repository;
  const UpdateProductUsecase(this._repository);

  Future<Either<Failure, ProductEntity>> call({
    required String id,
    required String name,
    required String sku,
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

    // Validasi harga
    if (sellingPrice < 0) {
      return left(const ValidationFailure('Harga jual tidak boleh negatif'));
    }
    if (costPrice != null && costPrice < 0) {
      return left(const ValidationFailure('Harga modal tidak boleh negatif'));
    }

    final trimmedSku = sku.trim().toUpperCase();
    if (trimmedSku.isEmpty) {
      return left(const ValidationFailure('SKU tidak boleh kosong'));
    }

    final trimmedUnit = unit.trim();
    if (trimmedUnit.isEmpty) {
      return left(const ValidationFailure('Satuan tidak boleh kosong'));
    }

    // Cek SKU unik (exclude produk ini sendiri)
    final skuCheck = await _repository.checkSkuExists(
      trimmedSku,
      excludeId: id,
    );
    final skuExists = skuCheck.fold((_) => false, (skuExists) => skuExists);
    if (skuExists) {
      return left(
        ValidationFailure('SKU "$trimmedSku" sudah digunakan produk lain'),
      );
    }

    // Cek barcode unik (jika diisi)
    final trimmedBarcode =
        barcode?.trim().isEmpty == true ? null : barcode?.trim();
    if (trimmedBarcode != null) {
      final bcCheck = await _repository.checkBarcodeExists(
        trimmedBarcode,
        excludeId: id,
      );
      final bcExists = bcCheck.fold((_) => false, (barcodeExists) => barcodeExists);
      if (bcExists) {
        return left(
          ValidationFailure(
            'Barcode "$trimmedBarcode" sudah digunakan produk lain',
          ),
        );
      }
    }

    // Ambil data lama
    final existing = await _repository.getById(id);
    return existing.fold(
      left,
      (old) => _repository.update(
        ProductEntity(
          id: old.id,
          name: trimmedName,
          sku: trimmedSku,
          sellingPrice: sellingPrice,
          costPrice: costPrice,
          categoryId: categoryId.isEmpty ? DbConstants.defaultCategoryId : categoryId,
          unit: trimmedUnit,
          barcode: trimmedBarcode,
          imagePath: imagePath ?? old.imagePath,
          isActive: old.isActive,
          isDeleted: old.isDeleted,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }
}
