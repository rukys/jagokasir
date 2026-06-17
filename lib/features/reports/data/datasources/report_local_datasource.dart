// lib/features/reports/data/datasources/report_local_datasource.dart

import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/daily_sales_entity.dart';
import '../../domain/entities/date_range.dart';
import '../models/category_report_model.dart';
import '../models/product_performance_model.dart';
import '../models/sales_summary_model.dart';

class ReportLocalDatasource {
  final Database? databaseOverride;

  const ReportLocalDatasource({this.databaseOverride});

  Future<Database> get _db async => databaseOverride ?? await DatabaseHelper.instance.database;

  /// Mengambil ringkasan penjualan (total revenue, transaksi, item terjual, payment methods)
  Future<SalesSummaryModel> getSalesSummary(DateRange period) async {
    final db = await _db;
    final startStr = period.start.toIso8601String();
    final endStr = period.end.toIso8601String();

    // 1. Query revenue & transaction count
    final summaryResult = await db.rawQuery(
      '''
      SELECT 
        SUM(${DbConstants.colTotal}) as total_revenue, 
        COUNT(${DbConstants.colId}) as total_transactions 
      FROM ${DbConstants.tTransactions} 
      WHERE ${DbConstants.colStatus} = 'COMPLETED' 
        AND ${DbConstants.colCreatedAt} >= ? 
        AND ${DbConstants.colCreatedAt} <= ?
      ''',
      [startStr, endStr],
    );

    // 2. Query total items sold
    final itemsResult = await db.rawQuery(
      '''
      SELECT SUM(ti.${DbConstants.colQuantity}) as total_items
      FROM ${DbConstants.tTxnItems} ti
      INNER JOIN ${DbConstants.tTransactions} t ON ti.${DbConstants.colTransactionId} = t.${DbConstants.colId}
      WHERE t.${DbConstants.colStatus} = 'COMPLETED'
        AND t.${DbConstants.colCreatedAt} >= ?
        AND t.${DbConstants.colCreatedAt} <= ?
      ''',
      [startStr, endStr],
    );

    // 3. Query revenue grouped by payment method
    final paymentsResult = await db.rawQuery(
      '''
      SELECT 
        ${DbConstants.colPaymentMethod}, 
        SUM(${DbConstants.colTotal}) as method_revenue
      FROM ${DbConstants.tTransactions}
      WHERE ${DbConstants.colStatus} = 'COMPLETED'
        AND ${DbConstants.colCreatedAt} >= ?
        AND ${DbConstants.colCreatedAt} <= ?
      GROUP BY ${DbConstants.colPaymentMethod}
      ''',
      [startStr, endStr],
    );

    // Map payment methods to final dictionary
    final Map<String, double> paymentMethods = {
      'CASH': 0.0,
      'TRANSFER': 0.0,
      'QRIS': 0.0,
      'DEBIT': 0.0,
      'CREDIT': 0.0,
    };

    for (final row in paymentsResult) {
      final method = row[DbConstants.colPaymentMethod] as String?;
      final revenue = (row['method_revenue'] as num?)?.toDouble() ?? 0.0;
      if (method != null && paymentMethods.containsKey(method)) {
        paymentMethods[method] = revenue;
      }
    }

    final summaryMap = Map<String, dynamic>.from(summaryResult.first);
    summaryMap['total_items'] = itemsResult.first['total_items'];
    return SalesSummaryModel.fromMap(summaryMap, paymentMethods, period);
  }

  /// Mengambil performa produk berdasarkan rentang tanggal
  Future<List<ProductPerformanceModel>> getProductPerformance(
    DateRange period, {
    required bool sortByQty,
  }) async {
    final db = await _db;
    final startStr = period.start.toIso8601String();
    final endStr = period.end.toIso8601String();

    final orderField = sortByQty ? 'total_qty' : 'total_revenue';

    final rows = await db.rawQuery(
      '''
      SELECT 
        ti.${DbConstants.colProductId} as product_id,
        ti.${DbConstants.colProductName} as product_name,
        ti.${DbConstants.colProductSku} as product_sku,
        SUM(ti.${DbConstants.colQuantity}) as total_qty,
        SUM(ti.${DbConstants.colLineTotal}) as total_revenue,
        CASE 
          WHEN SUM(CASE WHEN ti.${DbConstants.colCostPrice} IS NULL THEN 1 ELSE 0 END) > 0 THEN NULL 
          ELSE SUM(ti.${DbConstants.colQuantity} * ti.${DbConstants.colCostPrice}) 
        END as total_cost
      FROM ${DbConstants.tTxnItems} ti
      INNER JOIN ${DbConstants.tTransactions} t ON ti.${DbConstants.colTransactionId} = t.${DbConstants.colId}
      WHERE t.${DbConstants.colStatus} = 'COMPLETED'
        AND t.${DbConstants.colCreatedAt} >= ?
        AND t.${DbConstants.colCreatedAt} <= ?
      GROUP BY ti.${DbConstants.colProductId}, ti.${DbConstants.colProductName}, ti.${DbConstants.colProductSku}
      ORDER BY $orderField DESC
      ''',
      [startStr, endStr],
    );

    return rows.map((r) => ProductPerformanceModel.fromMap(r)).toList();
  }

  /// Mengambil kontribusi kategori berdasarkan rentang tanggal
  Future<List<CategoryReportModel>> getCategoryReport(DateRange period) async {
    final db = await _db;
    final startStr = period.start.toIso8601String();
    final endStr = period.end.toIso8601String();

    // 1. Get raw category aggregations
    // We join categories with products to get category name. Since uncategorized is seeded, we join all.
    final rows = await db.rawQuery(
      '''
      SELECT 
        c.${DbConstants.colName} as category_name,
        COUNT(DISTINCT t.${DbConstants.colId}) as transaction_count,
        SUM(ti.${DbConstants.colQuantity}) as total_qty,
        SUM(ti.${DbConstants.colLineTotal}) as total_revenue
      FROM ${DbConstants.tTxnItems} ti
      INNER JOIN ${DbConstants.tTransactions} t ON ti.${DbConstants.colTransactionId} = t.${DbConstants.colId}
      INNER JOIN ${DbConstants.tProducts} p ON ti.${DbConstants.colProductId} = p.${DbConstants.colId}
      INNER JOIN ${DbConstants.tCategories} c ON p.${DbConstants.colCategoryId} = c.${DbConstants.colId}
      WHERE t.${DbConstants.colStatus} = 'COMPLETED'
        AND t.${DbConstants.colCreatedAt} >= ?
        AND t.${DbConstants.colCreatedAt} <= ?
      GROUP BY c.${DbConstants.colId}, c.${DbConstants.colName}
      ORDER BY total_revenue DESC
      ''',
      [startStr, endStr],
    );

    // Calculate total revenue of all categories in this list
    double totalRevenueSum = 0.0;
    for (final row in rows) {
      totalRevenueSum += (row['total_revenue'] as num?)?.toDouble() ?? 0.0;
    }

    return rows.map((r) => CategoryReportModel.fromMap(r, totalRevenueSum)).toList();
  }

  /// Mengambil data tren harian di mana hari-hari kosong diisi dengan 0
  Future<List<DailySalesEntity>> getDailySalesTrend(DateRange period) async {
    final startStr = period.start.toIso8601String();
    final endStr = period.end.toIso8601String();

    // 1. Buat map default untuk setiap hari dalam rentang (menggunakan local time)
    final Map<String, DailySalesEntity> trendMap = {};
    DateTime current = period.start;
    while (current.isBefore(period.end) || current.isAtSameMomentAs(period.end)) {
      final dateKey =
          '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
      trendMap[dateKey] = DailySalesEntity(
        date: DateTime(current.year, current.month, current.day),
        revenue: 0.0,
        transactionCount: 0,
      );
      current = current.add(const Duration(days: 1));
    }

    // 2. Query data transaksi yang dikelompokkan berdasarkan tanggal local
    final db = await _db;
    // Gunakan substring untuk memotong tanggal 'YYYY-MM-DD' dari created_at
    final rows = await db.rawQuery(
      '''
      SELECT 
        SUBSTR(${DbConstants.colCreatedAt}, 1, 10) as sales_date,
        SUM(${DbConstants.colTotal}) as daily_revenue,
        COUNT(${DbConstants.colId}) as txn_count
      FROM ${DbConstants.tTransactions}
      WHERE ${DbConstants.colStatus} = 'COMPLETED'
        AND ${DbConstants.colCreatedAt} >= ?
        AND ${DbConstants.colCreatedAt} <= ?
      GROUP BY SUBSTR(${DbConstants.colCreatedAt}, 1, 10)
      ''',
      [startStr, endStr],
    );

    for (final row in rows) {
      final dateKey = row['sales_date'] as String?;
      if (dateKey != null && trendMap.containsKey(dateKey)) {
        final revenue = (row['daily_revenue'] as num?)?.toDouble() ?? 0.0;
        final count = (row['txn_count'] as num?)?.toInt() ?? 0;

        final parts = dateKey.split('-');
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2]);

        trendMap[dateKey] = DailySalesEntity(
          date: DateTime(y, m, d),
          revenue: revenue,
          transactionCount: count,
        );
      }
    }

    final sortedTrend = trendMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedTrend;
  }

  /// Mengambil nama toko dari store_config
  Future<String> getStoreName() async {
    final db = await _db;
    final rows = await db.query(
      DbConstants.tStoreConfig,
      columns: [DbConstants.colStoreName],
      where: '${DbConstants.colId} = ?',
      whereArgs: [DbConstants.storeConfigId],
      limit: 1,
    );

    if (rows.isEmpty) return 'Toko Saya';
    return rows.first[DbConstants.colStoreName] as String? ?? 'Toko Saya';
  }
}
