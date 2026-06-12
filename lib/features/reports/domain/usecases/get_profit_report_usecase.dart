import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../entities/date_range.dart';
import '../entities/product_performance_entity.dart';
import '../repositories/report_repository.dart';

class GetProfitReportUsecase {
  final ReportRepository _repository;

  const GetProfitReportUsecase(this._repository);

  Future<Either<Failure, List<ProductPerformanceEntity>>> call({
    required StaffRole currentUserRole,
    required DateRange period,
  }) async {
    // 1. Enforce Owner-only guard
    if (currentUserRole != StaffRole.owner) {
      return left(const PermissionFailure('Akses terbatas. Hanya Owner yang dapat melihat laporan laba kotor.'));
    }

    // Profit report uses product performance metrics (sorted by revenue/sales default)
    return _repository.getProductPerformance(period, sortByQty: false);
  }
}
