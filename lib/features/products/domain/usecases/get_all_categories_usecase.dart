import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetAllCategoriesUsecase {
  final CategoryRepository _repository;
  const GetAllCategoriesUsecase(this._repository);

  Future<Either<Failure, List<CategoryEntity>>> call() =>
      _repository.getAll();
}
