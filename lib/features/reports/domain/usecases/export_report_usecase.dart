import 'dart:io';
import 'package:csv/csv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/error/failures.dart';

class ExportReportUsecase {
  const ExportReportUsecase();

  /// Share formatted rows as a CSV file using system Share Sheet.
  Future<Either<Failure, Unit>> shareCsv({
    required String fileName,
    required List<List<dynamic>> csvData,
  }) async {
    try {
      final csvString = const ListToCsvConverter().convert(csvData);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csvString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: fileName.replaceAll('.csv', ''),
      );

      return right(unit);
    } catch (error) {
      return left(FileFailure('Gagal mengekspor laporan ke CSV: $error'));
    }
  }

  /// Share raw bytes of a PDF file using system Share Sheet.
  Future<Either<Failure, Unit>> sharePdf({
    required String fileName,
    required List<int> pdfBytes,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: fileName.replaceAll('.pdf', ''),
      );

      return right(unit);
    } catch (error) {
      return left(FileFailure('Gagal mengekspor laporan ke PDF: $error'));
    }
  }
}
