// lib/features/reports/data/repositories/report_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category_report_entity.dart';
import '../../domain/entities/daily_sales_entity.dart';
import '../../domain/entities/date_range.dart';
import '../../domain/entities/product_performance_entity.dart';
import '../../domain/entities/sales_summary_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDatasource _datasource;

  const ReportRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, SalesSummaryEntity>> getSalesSummary(DateRange period) async {
    try {
      final summary = await _datasource.getSalesSummary(period);
      return right(summary);
    } catch (error) {
      return left(DbFailure('Gagal memuat ringkasan penjualan: $error'));
    }
  }

  @override
  Future<Either<Failure, List<ProductPerformanceEntity>>> getProductPerformance(
    DateRange period, {
    required bool sortByQty,
  }) async {
    try {
      final list = await _datasource.getProductPerformance(period, sortByQty: sortByQty);
      return right(list);
    } catch (error) {
      return left(DbFailure('Gagal memuat performa produk: $error'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryReportEntity>>> getCategoryReport(DateRange period) async {
    try {
      final list = await _datasource.getCategoryReport(period);
      return right(list);
    } catch (error) {
      return left(DbFailure('Gagal memuat laporan kategori: $error'));
    }
  }

  @override
  Future<Either<Failure, List<DailySalesEntity>>> getDailySalesTrend(DateRange period) async {
    try {
      final list = await _datasource.getDailySalesTrend(period);
      return right(list);
    } catch (error) {
      return left(DbFailure('Gagal memuat tren penjualan harian: $error'));
    }
  }

  @override
  Future<Either<Failure, String>> getStoreName() async {
    try {
      final name = await _datasource.getStoreName();
      return right(name);
    } catch (error) {
      return left(DbFailure('Gagal mengambil nama toko: $error'));
    }
  }
}
