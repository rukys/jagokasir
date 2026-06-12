import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class ImportProductsCsvUsecase {
  final ProductRepository _repository;
  const ImportProductsCsvUsecase(this._repository);

  Future<Either<Failure, ImportResult>> call(String csvContent) async {
    if (csvContent.trim().isEmpty) {
      return left(const ValidationFailure('File CSV kosong'));
    }
    return _repository.importCsv(csvContent);
  }
}
