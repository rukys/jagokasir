import 'package:flutter_test/flutter_test.dart';
import 'package:pos_kasir/core/constants/db_constants.dart';
import 'package:pos_kasir/features/reports/data/datasources/report_local_datasource.dart';
import 'package:pos_kasir/features/reports/domain/entities/date_range.dart';
import 'package:sqflite/sqflite.dart';

class FakeDatabase extends Fake implements Database {
  final Map<String, List<Map<String, Object?>>> rawQueryStubs = {};
  List<Map<String, Object?>> queryStubResult = [];
  final List<String> queriesRun = [];
  final List<List<Object?>> queryParamsRun = [];

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    queriesRun.add(sql);
    queryParamsRun.add(arguments ?? []);
    
    for (final entry in rawQueryStubs.entries) {
      if (sql.contains(entry.key)) {
        return entry.value;
      }
    }
    return [];
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    queriesRun.add('query:$table');
    return queryStubResult;
  }
}

void main() {
  late FakeDatabase fakeDb;
  late ReportLocalDatasource datasource;
  final testPeriod = DateRange(
    start: DateTime(2026, 6, 17, 0, 0, 0),
    end: DateTime(2026, 6, 17, 23, 59, 59),
  );

  setUp(() {
    fakeDb = FakeDatabase();
    datasource = ReportLocalDatasource(databaseOverride: fakeDb);
  });

  group('ReportLocalDatasource Tests', () {
    test('getSalesSummary returns mapped data from multiple query stubs', () async {
      // 1. Stub revenue & transaction query
      fakeDb.rawQueryStubs['SUM(${DbConstants.colTotal}) as total_revenue'] = [
        {'total_revenue': 1500000.0, 'total_transactions': 10},
      ];

      // 2. Stub items sold query
      fakeDb.rawQueryStubs['SUM(ti.${DbConstants.colQuantity}) as total_items'] = [
        {'total_items': 25.0},
      ];

      // 3. Stub payment method revenue query
      fakeDb.rawQueryStubs['GROUP BY ${DbConstants.colPaymentMethod}'] = [
        {'payment_method': 'CASH', 'method_revenue': 1000000.0},
        {'payment_method': 'QRIS', 'method_revenue': 500000.0},
      ];

      final result = await datasource.getSalesSummary(testPeriod);

      expect(result.totalRevenue, 1500000.0);
      expect(result.totalTransactions, 10);
      expect(result.totalItemsSold, 25.0);
      expect(result.averageTransactionValue, 150000.0);
      expect(result.revenueByPaymentMethod['CASH'], 1000000.0);
      expect(result.revenueByPaymentMethod['QRIS'], 500000.0);
      expect(result.revenueByPaymentMethod['TRANSFER'], 0.0); // Defaults to 0.0
    });

    test('getProductPerformance returns mapped product performance models', () async {
      fakeDb.rawQueryStubs['SUM(ti.${DbConstants.colLineTotal}) as total_revenue'] = [
        {
          'product_id': 'p1',
          'product_name': 'Kopi Hitam',
          'product_sku': 'SKU-KOPI',
          'total_qty': 15.0,
          'total_revenue': 300000.0,
          'total_cost': 120000.0,
        }
      ];

      final result = await datasource.getProductPerformance(testPeriod, sortByQty: true);

      expect(result, hasLength(1));
      final perf = result.first;
      expect(perf.productId, 'p1');
      expect(perf.productName, 'Kopi Hitam');
      expect(perf.productSku, 'SKU-KOPI');
      expect(perf.totalQuantitySold, 15.0);
      expect(perf.totalRevenue, 300000.0);
      expect(perf.totalCostPrice, 120000.0);
      expect(perf.grossProfit, 180000.0); // 300k - 120k
    });

    test('getCategoryReport returns category contribution models', () async {
      fakeDb.rawQueryStubs['INNER JOIN ${DbConstants.tCategories}'] = [
        {
          'category_name': 'Makanan',
          'transaction_count': 4,
          'total_qty': 8.0,
          'total_revenue': 160000.0,
        },
        {
          'category_name': 'Minuman',
          'transaction_count': 6,
          'total_qty': 12.0,
          'total_revenue': 240000.0,
        }
      ];

      final result = await datasource.getCategoryReport(testPeriod);

      expect(result, hasLength(2));
      // First is Makanan (ordered by SQL descending? In our stub we returned Makanan first)
      expect(result[0].categoryName, 'Makanan');
      expect(result[0].totalRevenue, 160000.0);
      expect(result[0].percentage, closeTo(0.4, 0.01)); // 160k / (160k + 240k)

      expect(result[1].categoryName, 'Minuman');
      expect(result[1].totalRevenue, 240000.0);
      expect(result[1].percentage, closeTo(0.6, 0.01)); // 240k / (160k + 240k)
    });

    test('getDailySalesTrend returns sorted trend daily trend list with missing days filled with 0', () async {
      // Stub daily query for only one day (2026-06-17)
      fakeDb.rawQueryStubs['SUBSTR(${DbConstants.colCreatedAt}, 1, 10)'] = [
        {'sales_date': '2026-06-17', 'daily_revenue': 100000.0, 'txn_count': 2},
      ];

      // Define a 3-day range: June 16 to June 18
      final multiDayPeriod = DateRange(
        start: DateTime(2026, 6, 16),
        end: DateTime(2026, 6, 18),
      );

      final result = await datasource.getDailySalesTrend(multiDayPeriod);

      // Should return 3 items sorted by date
      expect(result, hasLength(3));

      // June 16: Empty (0)
      expect(result[0].date.day, 16);
      expect(result[0].revenue, 0.0);
      expect(result[0].transactionCount, 0);

      // June 17: Has data (100k, 2 txn)
      expect(result[1].date.day, 17);
      expect(result[1].revenue, 100000.0);
      expect(result[1].transactionCount, 2);

      // June 18: Empty (0)
      expect(result[2].date.day, 18);
      expect(result[2].revenue, 0.0);
      expect(result[2].transactionCount, 0);
    });

    test('getStoreName queries store_config and returns store name', () async {
      fakeDb.queryStubResult = [
        {DbConstants.colStoreName: 'Warkop Jago'},
      ];

      final result = await datasource.getStoreName();

      expect(result, 'Warkop Jago');
      expect(fakeDb.queriesRun.first, 'query:${DbConstants.tStoreConfig}');
    });

    test('getStoreName returns default when store_config query is empty', () async {
      fakeDb.queryStubResult = [];

      final result = await datasource.getStoreName();

      expect(result, 'Toko Saya');
    });
  });
}
