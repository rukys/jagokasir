
import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/invoice_generator.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_item_model.dart';
import '../models/transaction_model.dart';

class TransactionLocalDatasource {
  const TransactionLocalDatasource();

  /// Menyimpan transaksi secara atomik (header + items + update stock + log ledger)
  Future<TransactionModel> checkout(TransactionModel transaction) async {
    final db = await DatabaseHelper.instance.database;
    return await db.transaction<TransactionModel>((txn) async {
      // 1. Generate nomor invoice
      final invoiceNumber = await InvoiceGenerator.generate(txn);

      // 2. Buat model transaksi baru dengan invoice number terisi
      final txnModel = TransactionModel(
        id: transaction.id,
        invoiceNumber: invoiceNumber,
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
        items: transaction.items,
      );

      // 3. Simpan header transaksi
      await txn.insert(
        DbConstants.tTransactions,
        txnModel.toMap(),
      );

      // 4. Simpan setiap item transaksi dan potong stok
      for (final item in transaction.items) {
        final itemModel = TransactionItemModel(
          id: item.id,
          transactionId: txnModel.id,
          productId: item.productId,
          productName: item.productName,
          productSku: item.productSku,
          sellingPrice: item.sellingPrice,
          costPrice: item.costPrice,
          quantity: item.quantity,
          itemDiscountType: item.itemDiscountType,
          itemDiscountValue: item.itemDiscountValue,
          itemDiscountAmount: item.itemDiscountAmount,
          lineTotal: item.lineTotal,
        );

        await txn.insert(
          DbConstants.tTxnItems,
          itemModel.toMap(),
        );

        // Ambil info track stock produk dari tabel stocks
        final stockResult = await txn.query(
          DbConstants.tStocks,
          columns: [DbConstants.colTrackStock, DbConstants.colCurrentStock],
          where: '${DbConstants.colProductId} = ?',
          whereArgs: [item.productId],
        );

        if (stockResult.isNotEmpty) {
          final trackStock = (stockResult.first[DbConstants.colTrackStock] as int) == 1;
          final currentStock = (stockResult.first[DbConstants.colCurrentStock] as num).toDouble();

          if (trackStock) {
            final newStock = currentStock - item.quantity;

            // Update stok fisik
            await txn.update(
              DbConstants.tStocks,
              {DbConstants.colCurrentStock: newStock},
              where: '${DbConstants.colProductId} = ?',
              whereArgs: [item.productId],
            );

            // Tulis history stock ledger (SALE)
            await txn.insert(
              DbConstants.tStockLedger,
              {
                DbConstants.colId: UuidGenerator.generate(),
                DbConstants.colProductId: item.productId,
                DbConstants.colChangeAmount: -item.quantity,
                DbConstants.colStockAfter: newStock,
                DbConstants.colReason: 'SALE',
                DbConstants.colReferenceId: txnModel.id,
                DbConstants.colNote: 'Penjualan Invoice ${txnModel.invoiceNumber}',
                DbConstants.colStaffId: txnModel.staffId,
                DbConstants.colCreatedAt: DateTime.now().toIso8601String(),
              },
            );
          }
        }
      }

      return txnModel;
    });
  }

  /// Membatalkan transaksi (VOID) dan mengembalikan stok
  Future<bool> voidTransaction({
    required String transactionId,
    required String staffId,
    required String reason,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return await db.transaction<bool>((txn) async {
      // 1. Update status transaksi menjadi VOIDED
      final count = await txn.update(
        DbConstants.tTransactions,
        {
          DbConstants.colStatus: TransactionStatus.voided.toDbValue(),
          DbConstants.colVoidedAt: DateTime.now().toIso8601String(),
          DbConstants.colVoidedBy: staffId,
          DbConstants.colVoidReason: reason,
        },
        where: '${DbConstants.colId} = ?',
        whereArgs: [transactionId],
      );

      if (count == 0) return false;

      // 2. Tarik item transaksi untuk dikembalikan stoknya
      final itemsResult = await txn.query(
        DbConstants.tTxnItems,
        where: '${DbConstants.colTransactionId} = ?',
        whereArgs: [transactionId],
      );

      for (final itemRow in itemsResult) {
        final productId = itemRow[DbConstants.colProductId] as String;
        final quantity = (itemRow[DbConstants.colQuantity] as num).toDouble();

        // Cek setting stok produk
        final stockResult = await txn.query(
          DbConstants.tStocks,
          columns: [DbConstants.colTrackStock, DbConstants.colCurrentStock],
          where: '${DbConstants.colProductId} = ?',
          whereArgs: [productId],
        );

        if (stockResult.isNotEmpty) {
          final trackStock = (stockResult.first[DbConstants.colTrackStock] as int) == 1;
          final currentStock = (stockResult.first[DbConstants.colCurrentStock] as num).toDouble();

          if (trackStock) {
            final restoredStock = currentStock + quantity;

            // Kembalikan stok fisik
            await txn.update(
              DbConstants.tStocks,
              {DbConstants.colCurrentStock: restoredStock},
              where: '${DbConstants.colProductId} = ?',
              whereArgs: [productId],
            );

            // Tulis history stock ledger (VOID)
            await txn.insert(
              DbConstants.tStockLedger,
              {
                DbConstants.colId: UuidGenerator.generate(),
                DbConstants.colProductId: productId,
                DbConstants.colChangeAmount: quantity,
                DbConstants.colStockAfter: restoredStock,
                DbConstants.colReason: 'VOID',
                DbConstants.colReferenceId: transactionId,
                DbConstants.colNote: 'Void Transaksi: $reason',
                DbConstants.colStaffId: staffId,
                DbConstants.colCreatedAt: DateTime.now().toIso8601String(),
              },
            );
          }
        }
      }

      return true;
    });
  }

  /// Membaca detail transaksi beserta itemnya berdasarkan ID
  Future<TransactionModel> getTransactionById(String id) async {
    final db = await DatabaseHelper.instance.database;

    final list = await db.rawQuery(
      '''
      SELECT t.*, s.${DbConstants.colName} as staff_name
      FROM ${DbConstants.tTransactions} t
      LEFT JOIN ${DbConstants.tStaffs} s ON t.${DbConstants.colStaffId} = s.${DbConstants.colId}
      WHERE t.${DbConstants.colId} = ?
      ''',
      [id],
    );

    if (list.isEmpty) {
      throw Exception('Transaksi dengan ID $id tidak ditemukan');
    }

    final itemRows = await db.query(
      DbConstants.tTxnItems,
      where: '${DbConstants.colTransactionId} = ?',
      whereArgs: [id],
    );

    final items = itemRows.map((row) => TransactionItemModel.fromMap(row)).toList();

    return TransactionModel.fromMap(list.first, items);
  }

  /// Membaca daftar transaksi yang cocok dengan filter
  Future<List<TransactionModel>> getTransactionList({
    String? staffId,
    TransactionStatus? status,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (staffId != null) {
      whereClauses.add('t.${DbConstants.colStaffId} = ?');
      whereArgs.add(staffId);
    }

    if (status != null) {
      whereClauses.add('t.${DbConstants.colStatus} = ?');
      whereArgs.add(status.toDbValue());
    }

    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('t.${DbConstants.colInvoiceNumber} LIKE ?');
      whereArgs.add('%${query.trim()}%');
    }

    if (startDate != null) {
      whereClauses.add('t.${DbConstants.colCreatedAt} >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('t.${DbConstants.colCreatedAt} <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final whereString = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    final list = await db.rawQuery(
      '''
      SELECT t.*, s.${DbConstants.colName} as staff_name
      FROM ${DbConstants.tTransactions} t
      LEFT JOIN ${DbConstants.tStaffs} s ON t.${DbConstants.colStaffId} = s.${DbConstants.colId}
      $whereString
      ORDER BY t.${DbConstants.colCreatedAt} DESC
      ''',
      whereArgs,
    );

    final List<TransactionModel> txns = [];
    for (final row in list) {
      final txnId = row[DbConstants.colId] as String;

      final itemRows = await db.query(
        DbConstants.tTxnItems,
        where: '${DbConstants.colTransactionId} = ?',
        whereArgs: [txnId],
      );

      final items = itemRows.map((r) => TransactionItemModel.fromMap(r)).toList();
      txns.add(TransactionModel.fromMap(row, items));
    }

    return txns;
  }

  /// Menghitung jumlah transaksi pada hari tersebut (format YYYYMMDD)
  Future<int> getDailyInvoiceCount(String dateStr) async {
    final db = await DatabaseHelper.instance.database;

    final startOfDay = '${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}T00:00:00.000';
    final endOfDay = '${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}T23:59:59.999';

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${DbConstants.tTransactions}
      WHERE ${DbConstants.colCreatedAt} >= ? AND ${DbConstants.colCreatedAt} <= ?
      ''',
      [startOfDay, endOfDay],
    );

    return (result.first['count'] as int?) ?? 0;
  }
}
