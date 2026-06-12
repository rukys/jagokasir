import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDatasource _datasource;
  const CategoryRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAll() async {
    try {
      final result = await _datasource.getAll();
      return right(result);
    } catch (e) {
      return left(DbFailure('Gagal memuat kategori: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getById(String id) async {
    try {
      final result = await _datasource.getById(id);
      return right(result);
    } on NotFoundException catch (e) {
      return left(NotFoundFailure(e.message));
    } catch (e) {
      return left(DbFailure('Gagal memuat kategori: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> create(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final result = await _datasource.insert(model);
      return right(result);
    } on ConstraintException catch (e) {
      return left(ValidationFailure(e.message));
    } catch (e) {
      return left(DbFailure('Gagal menyimpan kategori: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> update(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final result = await _datasource.update(model);
      return right(result);
    } on NotFoundException catch (e) {
      return left(NotFoundFailure(e.message));
    } catch (e) {
      return left(DbFailure('Gagal memperbarui kategori: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _datasource.delete(id);
      return right(unit);
    } catch (e) {
      return left(DbFailure('Gagal menghapus kategori: $e'));
    }
  }
}
