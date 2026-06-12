import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class CreateCategoryUsecase {
  final CategoryRepository _repository;
  const CreateCategoryUsecase(this._repository);

  Future<Either<Failure, CategoryEntity>> call({
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

    final now = DateTime.now();
    final category = CategoryEntity(
      id: UuidGenerator.generate(),
      name: trimmed,
      colorHex: colorHex,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    );
    return _repository.create(category);
  }
}
