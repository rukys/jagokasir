// lib/features/stock/domain/usecases/adjust_stock_usecase.dart

import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../entities/stock_entity.dart';
import '../repositories/stock_repository.dart';

/// Reason yang diizinkan dari luar system (manual adjustment).
/// SALE dan VOID hanya dari internal Cashier session.
const _allowedReasons = {'RESTOCK', 'ADJUSTMENT'};

class AdjustStockUsecase {
  final StockRepository _repository;
  const AdjustStockUsecase(this._repository);

  Future<Either<Failure, StockEntity>> call({
    required String productId,
    required double changeAmount,
    required String reason,
    String? note,
    String? staffId,
  }) async {
    // Validasi 1: changeAmount tidak boleh 0
    if (changeAmount == 0) {
      return left(const ValidationFailure('Jumlah adjustment tidak boleh 0'));
    }

    // Validasi 2: reason harus RESTOCK atau ADJUSTMENT
    if (!_allowedReasons.contains(reason.toUpperCase())) {
      return left(
        ValidationFailure(
          'Reason tidak valid. Gunakan: ${_allowedReasons.join(", ")}',
        ),
      );
    }

    // Validasi 3: note wajib untuk ADJUSTMENT
    if (reason.toUpperCase() == 'ADJUSTMENT' &&
        (note == null || note.trim().isEmpty)) {
      return left(
        const ValidationFailure('Catatan wajib diisi untuk alasan Koreksi/Adjustment'),
      );
    }

    // Validasi 4: cek allow_negative_stock jika changeAmount negatif
    if (changeAmount < 0) {
      // Ambil setting allow_negative_stock dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final allowNegative = prefs.getBool('allow_negative_stock') ?? false;

      if (!allowNegative) {
        final stockResult = await _repository.getStockByProduct(productId);
        final failureOrNull = stockResult.fold<Failure?>(
          (f) => f,
          (stock) {
            final resultStock = stock.currentStock + changeAmount;
            if (resultStock < 0) {
              return ValidationFailure(
                'Stok tidak mencukupi. Stok saat ini: ${stock.currentStock} ${stock.productUnit}',
              );
            }
            return null;
          },
        );

        if (failureOrNull != null) {
          return left(failureOrNull);
        }
      }
    }

    return _repository.adjustStock(
      productId: productId,
      changeAmount: changeAmount,
      reason: reason.toUpperCase(),
      note: note?.trim(),
      staffId: staffId,
    );
  }
}
