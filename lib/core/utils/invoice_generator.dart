import 'package:sqflite/sqflite.dart';

import '../constants/db_constants.dart';

/// Generator nomor invoice transaksi.
///
/// Format: `INV-YYYYMMDD-XXXX`
/// - YYYYMMDD: tanggal hari ini
/// - XXXX: counter 4 digit per hari, mulai dari 0001
///
/// Contoh: `INV-20240115-0001`, `INV-20240115-0002`
class InvoiceGenerator {
  InvoiceGenerator._();

  /// Generate nomor invoice berikutnya berdasarkan transaksi hari ini.
  /// [db] harus database yang sudah terbuka.
  static Future<String> generate(DatabaseExecutor db) async {
    final now = DateTime.now();
    final dateStr = _formatDate(now);

    // Hitung jumlah transaksi hari ini (termasuk yang VOIDED)
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
      999,
    ).toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${DbConstants.tTransactions}
      WHERE ${DbConstants.colCreatedAt} >= ? AND ${DbConstants.colCreatedAt} <= ?
      ''',
      [startOfDay, endOfDay],
    );

    final count = (result.first['count'] as int?) ?? 0;
    final counter = (count + 1).toString().padLeft(4, '0');

    return 'INV-$dateStr-$counter';
  }

  /// Format date ke YYYYMMDD.
  static String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }
}
