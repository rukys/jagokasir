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
    } catch (error) {
      return left(DbFailure('Gagal memuat kategori: $error'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getById(String id) async {
    try {
      final result = await _datasource.getById(id);
      return right(result);
    } on NotFoundException catch (error) {
      return left(NotFoundFailure(error.message));
    } catch (error) {
      return left(DbFailure('Gagal memuat kategori: $error'));
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
    } on ConstraintException catch (error) {
      return left(ValidationFailure(error.message));
    } catch (error) {
      return left(DbFailure('Gagal menyimpan kategori: $error'));
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
    } on NotFoundException catch (error) {
      return left(NotFoundFailure(error.message));
    } catch (error) {
      return left(DbFailure('Gagal memperbarui kategori: $error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _datasource.delete(id);
      return right(unit);
    } catch (error) {
      return left(DbFailure('Gagal menghapus kategori: $error'));
    }
  }
}
