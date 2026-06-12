import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_report_entity.dart';
import '../entities/daily_sales_entity.dart';
import '../entities/date_range.dart';
import '../entities/product_performance_entity.dart';
import '../entities/sales_summary_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, SalesSummaryEntity>> getSalesSummary(DateRange period);

  Future<Either<Failure, List<ProductPerformanceEntity>>> getProductPerformance(
    DateRange period, {
    required bool sortByQty,
  });

  Future<Either<Failure, List<CategoryReportEntity>>> getCategoryReport(DateRange period);

  Future<Either<Failure, List<DailySalesEntity>>> getDailySalesTrend(DateRange period);

  Future<Either<Failure, String>> getStoreName();
}
