// lib/features/stock/domain/usecases/update_stock_settings_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/stock_entity.dart';
import '../repositories/stock_repository.dart';

class UpdateStockSettingsUsecase {
  final StockRepository _repository;
  const UpdateStockSettingsUsecase(this._repository);

  Future<Either<Failure, StockEntity>> call({
    required String productId,
    required double minimumStock,
    required bool trackStock,
  }) {
    if (minimumStock < 0) {
      return Future.value(
        left(const ValidationFailure('Stok minimum tidak boleh negatif')),
      );
    }
    return _repository.updateStockSettings(
      productId: productId,
      minimumStock: minimumStock,
      trackStock: trackStock,
    );
  }
}
