import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/db_constants.dart';
import '../../../../core/error/failures.dart';
import '../repositories/category_repository.dart';

class DeleteCategoryUsecase {
  final CategoryRepository _repository;
  const DeleteCategoryUsecase(this._repository);

  Future<Either<Failure, Unit>> call(String id) async {
    // Block hapus kategori default
    if (id == DbConstants.defaultCategoryId) {
      return left(
        const ValidationFailure(
          'Kategori "Uncategorized" tidak bisa dihapus',
        ),
      );
    }
    return _repository.delete(id);
  }
}
