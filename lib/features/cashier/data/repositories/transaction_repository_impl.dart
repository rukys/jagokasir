import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_item_model.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDatasource _datasource;

  const TransactionRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, TransactionEntity>> checkout(TransactionEntity transaction) async {
    try {
      final itemsModel = transaction.items.map((e) {
        return TransactionItemModel(
          id: e.id,
          transactionId: e.transactionId,
          productId: e.productId,
          productName: e.productName,
          productSku: e.productSku,
          sellingPrice: e.sellingPrice,
          costPrice: e.costPrice,
          quantity: e.quantity,
          itemDiscountType: e.itemDiscountType,
          itemDiscountValue: e.itemDiscountValue,
          itemDiscountAmount: e.itemDiscountAmount,
          lineTotal: e.lineTotal,
        );
      }).toList();

      final model = TransactionModel(
        id: transaction.id,
        invoiceNumber: transaction.invoiceNumber,
        staffId: transaction.staffId,
        staffName: transaction.staffName,
        subtotal: transaction.subtotal,
        discountType: transaction.discountType,
        discountValue: transaction.discountValue,
        discountAmount: transaction.discountAmount,
        taxRate: transaction.taxRate,
        taxIsInclusive: transaction.taxIsInclusive,
        taxAmount: transaction.taxAmount,
        total: transaction.total,
        paymentMethod: transaction.paymentMethod,
        paymentReceived: transaction.paymentReceived,
        changeAmount: transaction.changeAmount,
        status: transaction.status,
        voidReason: transaction.voidReason,
        note: transaction.note,
        createdAt: transaction.createdAt,
        items: itemsModel,
      );

      final result = await _datasource.checkout(model);
      return right(result);
    } catch (e) {
      return left(DbFailure('Gagal menyimpan transaksi: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> voidTransaction({
    required String transactionId,
    required String staffId,
    required String reason,
  }) async {
    try {
      final success = await _datasource.voidTransaction(
        transactionId: transactionId,
        staffId: staffId,
        reason: reason,
      );
      return right(success);
    } catch (e) {
      return left(DbFailure('Gagal membatalkan transaksi: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id) async {
    try {
      final result = await _datasource.getTransactionById(id);
      return right(result);
    } catch (e) {
      return left(DbFailure('Transaksi tidak ditemukan: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionList({
    String? staffId,
    TransactionStatus? status,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _datasource.getTransactionList(
        staffId: staffId,
        status: status,
        query: query,
        startDate: startDate,
        endDate: endDate,
      );
      return right(result);
    } catch (e) {
      return left(DbFailure('Gagal memuat daftar transaksi: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getDailyInvoiceCount(String dateStr) async {
    try {
      final count = await _datasource.getDailyInvoiceCount(dateStr);
      return right(count);
    } catch (e) {
      return left(DbFailure('Gagal menghitung transaksi harian: $e'));
    }
  }
}
