import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/daily_sales_entity.dart';
import '../entities/date_range.dart';
import '../repositories/report_repository.dart';

class GetDailySalesTrendUsecase {
  final ReportRepository _repository;

  const GetDailySalesTrendUsecase(this._repository);

  Future<Either<Failure, List<DailySalesEntity>>> call(DateRange period) async {
    return _repository.getDailySalesTrend(period);
  }
}
