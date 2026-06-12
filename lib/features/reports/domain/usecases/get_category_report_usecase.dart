import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_report_entity.dart';
import '../entities/date_range.dart';
import '../repositories/report_repository.dart';

class GetCategoryReportUsecase {
  final ReportRepository _repository;

  const GetCategoryReportUsecase(this._repository);

  Future<Either<Failure, List<CategoryReportEntity>>> call(DateRange period) async {
    return _repository.getCategoryReport(period);
  }
}
