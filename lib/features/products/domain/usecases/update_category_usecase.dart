import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUsecase {
  final CategoryRepository _repository;
  const UpdateCategoryUsecase(this._repository);

  Future<Either<Failure, CategoryEntity>> call({
    required String id,
    required String name,
    String? colorHex,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return left(const ValidationFailure('Nama kategori tidak boleh kosong'));
    }
    if (trimmed.length > 50) {
      return left(const ValidationFailure('Nama kategori maksimal 50 karakter'));
    }

    // Ambil data lama dulu
    final existing = await _repository.getById(id);
    return existing.fold(
      left,
      (cat) => _repository.update(
        CategoryEntity(
          id: cat.id,
          name: trimmed,
          colorHex: colorHex ?? cat.colorHex,
          isDeleted: cat.isDeleted,
          createdAt: cat.createdAt,
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }
}
