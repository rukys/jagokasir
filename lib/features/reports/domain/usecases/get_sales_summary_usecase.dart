import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/date_range.dart';
import '../entities/sales_summary_entity.dart';
import '../repositories/report_repository.dart';

class GetSalesSummaryUsecase {
  final ReportRepository _repository;

  const GetSalesSummaryUsecase(this._repository);

  Future<Either<Failure, SalesSummaryEntity>> call(DateRange period) async {
    return _repository.getSalesSummary(period);
  }
}
