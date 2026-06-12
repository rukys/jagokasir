import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/date_range.dart';
import '../entities/product_performance_entity.dart';
import '../repositories/report_repository.dart';

class GetProductPerformanceUsecase {
  final ReportRepository _repository;

  const GetProductPerformanceUsecase(this._repository);

  Future<Either<Failure, List<ProductPerformanceEntity>>> call(
    DateRange period, {
    required bool sortByQty,
  }) async {
    return _repository.getProductPerformance(period, sortByQty: sortByQty);
  }
}
