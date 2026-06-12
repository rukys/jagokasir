import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  /// Melakukan checkout transaksi (atomic DB transaction: simpan transaction, transaction_items, update stock, catat stock ledger)
  Future<Either<Failure, TransactionEntity>> checkout(TransactionEntity transaction);

  /// Membatalkan transaksi (void) dan mengembalikan stok yang berkurang
  Future<Either<Failure, bool>> voidTransaction({
    required String transactionId,
    required String staffId,
    required String reason,
  });

  /// Mendapatkan detail transaksi berdasarkan ID
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);

  /// Mendapatkan daftar riwayat transaksi terfilter
  Future<Either<Failure, List<TransactionEntity>>> getTransactionList({
    String? staffId,
    TransactionStatus? status,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Mendapatkan jumlah transaksi pada hari tertentu (format YYYYMMDD) untuk penomoran invoice
  Future<Either<Failure, int>> getDailyInvoiceCount(String dateStr);
}
