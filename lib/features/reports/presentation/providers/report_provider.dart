// lib/features/reports/presentation/providers/report_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cashier/domain/entities/transaction_entity.dart';
import '../../data/datasources/report_local_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/category_report_entity.dart';
import '../../domain/entities/daily_sales_entity.dart';
import '../../domain/entities/date_range.dart';
import '../../domain/entities/product_performance_entity.dart';
import '../../domain/entities/sales_summary_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/export_report_usecase.dart';
import '../../domain/usecases/get_category_report_usecase.dart';
import '../../domain/usecases/get_daily_sales_trend_usecase.dart';
import '../../domain/usecases/get_product_performance_usecase.dart';
import '../../domain/usecases/get_profit_report_usecase.dart';
import '../../domain/usecases/get_sales_summary_usecase.dart';

part 'report_provider.g.dart';

// ── Dependency Providers ────────────────────────────────────────────────────

@riverpod
ReportLocalDatasource reportLocalDatasource(Ref ref) {
  return const ReportLocalDatasource();
}

@riverpod
ReportRepository reportRepository(Ref ref) {
  return ReportRepositoryImpl(ref.watch(reportLocalDatasourceProvider));
}

@riverpod
GetSalesSummaryUsecase getSalesSummaryUsecase(Ref ref) {
  return GetSalesSummaryUsecase(ref.watch(reportRepositoryProvider));
}

@riverpod
GetProductPerformanceUsecase getProductPerformanceUsecase(Ref ref) {
  return GetProductPerformanceUsecase(ref.watch(reportRepositoryProvider));
}

@riverpod
GetCategoryReportUsecase getCategoryReportUsecase(Ref ref) {
  return GetCategoryReportUsecase(ref.watch(reportRepositoryProvider));
}

@riverpod
GetDailySalesTrendUsecase getDailySalesTrendUsecase(Ref ref) {
  return GetDailySalesTrendUsecase(ref.watch(reportRepositoryProvider));
}

@riverpod
GetProfitReportUsecase getProfitReportUsecase(Ref ref) {
  return GetProfitReportUsecase(ref.watch(reportRepositoryProvider));
}

@riverpod
ExportReportUsecase exportReportUsecase(Ref ref) {
  return const ExportReportUsecase();
}

// ── Data Providers ──────────────────────────────────────────────────────────

@riverpod
Future<SalesSummaryEntity> salesSummary(Ref ref, DateRange period) async {
  final usecase = ref.watch(getSalesSummaryUsecaseProvider);
  final result = await usecase(period);
  return result.fold((failure) => throw failure, (salesSummary) => salesSummary);
}

@riverpod
Future<List<DailySalesEntity>> dailyTrend(Ref ref, DateRange period) async {
  final usecase = ref.watch(getDailySalesTrendUsecaseProvider);
  final result = await usecase(period);
  return result.fold((failure) => throw failure, (trend) => trend);
}

@riverpod
Future<List<ProductPerformanceEntity>> productPerformance(
  Ref ref,
  DateRange period, {
  required bool sortByQty,
}) async {
  final usecase = ref.watch(getProductPerformanceUsecaseProvider);
  final result = await usecase(period, sortByQty: sortByQty);
  return result.fold((failure) => throw failure, (list) => list);
}

@riverpod
Future<List<CategoryReportEntity>> categoryReport(Ref ref, DateRange period) async {
  final usecase = ref.watch(getCategoryReportUsecaseProvider);
  final result = await usecase(period);
  return result.fold((failure) => throw failure, (list) => list);
}

@riverpod
Future<List<ProductPerformanceEntity>> profitReport(Ref ref, DateRange period) async {
  final staff = ref.watch(currentStaffProvider);
  if (staff == null) throw const PermissionFailure('Staff belum login');
  final usecase = ref.watch(getProfitReportUsecaseProvider);
  final result = await usecase(currentUserRole: staff.role, period: period);
  return result.fold((failure) => throw failure, (list) => list);
}

@riverpod
Future<String> storeName(Ref ref) async {
  final repository = ref.watch(reportRepositoryProvider);
  final result = await repository.getStoreName();
  return result.fold((failure) => 'Toko Saya', (name) => name);
}

// ── Export Notifier ──────────────────────────────────────────────────────────

@riverpod
class ExportReportNotifier extends _$ExportReportNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Menghasilkan format mata uang IDR sederhana tanpa intl dependency
  String _formatIdr(double val) {
    final str = val.toStringAsFixed(0);
    final sb = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      sb.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        sb.write('.');
      }
    }
    return 'Rp ${sb.toString().split('').reversed.join('')}';
  }

  /// Ekspor CSV daftar transaksi
  Future<void> exportTransactionsCsv({
    required List<TransactionEntity> transactions,
    required String fileName,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(exportReportUsecaseProvider);

    final csvData = [
      ['No. Invoice', 'Tanggal', 'Staff', 'Subtotal', 'Diskon', 'Pajak', 'Total', 'Metode Pembayaran', 'Status'],
      ...transactions.map((t) => [
            t.invoiceNumber,
            t.createdAt.toIso8601String(),
            t.staffName ?? t.staffId ?? '-',
            t.subtotal,
            t.discountAmount,
            t.taxAmount,
            t.total,
            t.paymentMethod.name.toUpperCase(),
            t.status.name.toUpperCase(),
          ],),
    ];

    final result = await usecase.shareCsv(
      fileName: fileName,
      csvData: csvData,
    );

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  /// Ekspor CSV performa produk
  Future<void> exportProductsCsv({
    required List<ProductPerformanceEntity> products,
    required String fileName,
    required bool isOwner,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(exportReportUsecaseProvider);

    final header = [
      'SKU',
      'Nama Produk',
      'Qty Terjual',
      'Total Pendapatan',
      if (isOwner) 'Total HPP',
      if (isOwner) 'Laba Kotor',
    ];

    final csvData = [
      header,
      ...products.map((p) => [
            p.productSku,
            p.productName,
            p.totalQuantitySold,
            p.totalRevenue,
            if (isOwner) p.totalCostPrice ?? 0.0,
            if (isOwner) p.grossProfit ?? 0.0,
          ],),
    ];

    final result = await usecase.shareCsv(
      fileName: fileName,
      csvData: csvData,
    );

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  /// Ekspor PDF ringkasan penjualan dengan preview cetak bawaan
  Future<void> exportSalesSummaryPdf({
    required String storeName,
    required SalesSummaryEntity summary,
    required List<DailySalesEntity> trend,
    required String periodLabel,
    required String fileName,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(exportReportUsecaseProvider);

    try {
      final pdfDoc = pw.Document();

      pdfDoc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header Toko & Judul Laporan
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    storeName.toUpperCase(),
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'LAPORAN RINGKASAN PENJUALAN',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Periode: $periodLabel',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                  pw.Divider(thickness: 2, color: PdfColors.teal800),
                  pw.SizedBox(height: 16),
                ],
              ),

              // Ringkasan Metrik (2x2 Grid)
              pw.GridView(
                crossAxisCount: 2,
                childAspectRatio: 0.35,
                children: [
                  _buildPdfMetricCard('Total Pendapatan', _formatIdr(summary.totalRevenue)),
                  _buildPdfMetricCard('Jumlah Transaksi', '${summary.totalTransactions} Transaksi'),
                  _buildPdfMetricCard('Produk Terjual', '${summary.totalItemsSold.toStringAsFixed(0)} item'),
                  _buildPdfMetricCard('Rata-rata Transaksi', _formatIdr(summary.averageTransactionValue)),
                ],
              ),
              pw.SizedBox(height: 24),

              // Rincian Penjualan Harian (Table)
              pw.Text(
                'Tren Penjualan Harian',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.teal50),
                    children: [
                      _buildPdfTableCell('Tanggal', isHeader: true),
                      _buildPdfTableCell('Jumlah Transaksi', isHeader: true),
                      _buildPdfTableCell('Pendapatan', isHeader: true),
                    ],
                  ),
                  // Table Rows
                  ...trend.map((t) {
                    final dateStr = '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}';
                    return pw.TableRow(
                      children: [
                        _buildPdfTableCell(dateStr),
                        _buildPdfTableCell('${t.transactionCount}'),
                        _buildPdfTableCell(_formatIdr(t.revenue)),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 32),

              // Footer Penutup
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Dicetak pada: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'JagoKasir Offline — Solusi UMKM',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      final pdfBytes = await pdfDoc.save();
      final result = await usecase.sharePdf(
        fileName: fileName,
        pdfBytes: pdfBytes,
      );

      state = result.fold(
        (failure) => AsyncError(failure, StackTrace.current),
        (_) => const AsyncData(null),
      );
    } catch (error) {
      state = AsyncError(FileFailure('Gagal membuat laporan PDF: $error'), StackTrace.current);
    }
  }

  pw.Widget _buildPdfMetricCard(String title, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(4),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.teal100, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }
}

// ── UI Period Providers ──────────────────────────────────────────────────────

final selectedReportPeriodProvider =
    StateProvider<ReportPeriod>((ref) => ReportPeriod.today);
final customDateRangeProvider = StateProvider<DateRange?>((ref) => null);

final currentReportDateRangeProvider = Provider<DateRange>((ref) {
  final period = ref.watch(selectedReportPeriodProvider);
  if (period == ReportPeriod.custom) {
    final customRange = ref.watch(customDateRangeProvider);
    if (customRange != null) return customRange;
  }
  return DateRange.fromPeriod(period);
});

