import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';

/// Abstract repository kategori — diimplementasikan di data layer.
abstract interface class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getAll();

  Future<Either<Failure, CategoryEntity>> getById(String id);

  Future<Either<Failure, CategoryEntity>> create(CategoryEntity category);

  Future<Either<Failure, CategoryEntity>> update(CategoryEntity category);

  /// Sebelum hapus: reassign semua produk di kategori ini ke Uncategorized.
  /// Block jika id == 'cat-uncategorized'.
  Future<Either<Failure, Unit>> delete(String id);
}
