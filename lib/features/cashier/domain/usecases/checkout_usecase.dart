import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../../../stock/domain/repositories/stock_repository.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class CheckoutUsecase {
  final TransactionRepository _transactionRepository;
  final StockRepository _stockRepository;

  const CheckoutUsecase(this._transactionRepository, this._stockRepository);

  Future<Either<Failure, TransactionEntity>> call(TransactionEntity transaction) async {
    // 1. Validasi: Transaksi harus punya item
    if (transaction.items.isEmpty) {
      return left(const ValidationFailure('Keranjang belanja kosong'));
    }

    // 2. Load setting allow_negative_stock dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final allowNegative = prefs.getBool('allow_negative_stock') ?? false;

    // 3. Cek stok untuk setiap item yang track_stock = true
    if (!allowNegative) {
      for (final item in transaction.items) {
        final stockResult = await _stockRepository.getStockByProduct(item.productId);
        
        final failureOrValidation = await stockResult.fold<Future<Either<Failure, void>>>(
          (failure) async => left(failure),
          (stock) async {
            if (stock.trackStock && stock.currentStock < item.quantity) {
              return left(
                ValidationFailure(
                  'Stok ${item.productName} tidak mencukupi. Tersisa: ${stock.currentStock} ${stock.productUnit}',
                ),
              );
            }
            return right(null);
          },
        );

        if (failureOrValidation.isLeft()) {
          // Kembalikan error stok pertama yang ditemukan
          return failureOrValidation.fold((failure) => left(failure), (_) => right(transaction));
        }
      }
    }

    // 4. Panggil repository untuk proses database atomic
    return _transactionRepository.checkout(transaction);
  }
}
