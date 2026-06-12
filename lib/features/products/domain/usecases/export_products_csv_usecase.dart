import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class ExportProductsCsvUsecase {
  final ProductRepository _repository;
  const ExportProductsCsvUsecase(this._repository);

  Future<Either<Failure, String>> call() => _repository.exportCsv();
}
