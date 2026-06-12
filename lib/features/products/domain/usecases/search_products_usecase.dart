import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class SearchProductsUsecase {
  final ProductRepository _repository;
  const SearchProductsUsecase(this._repository);

  Future<Either<Failure, List<ProductEntity>>> call({
    required String query,
    String? categoryId,
  }) async {
    final trimmed = query.trim();
    // Query kosong tidak error — return all (dengan filter kategori jika ada)
    return _repository.search(
      query: trimmed,
      categoryId: categoryId,
    );
  }
}
