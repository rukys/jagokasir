// lib/features/printer/data/repositories/printer_repository_impl.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as bt;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../cashier/domain/entities/transaction_entity.dart';
import '../../domain/entities/printer_entity.dart';
import '../../domain/entities/store_config_entity.dart';
import '../../domain/repositories/printer_repository.dart';
import '../datasources/printer_local_datasource.dart';
import '../models/printer_model.dart';

class PrinterRepositoryImpl implements PrinterRepository {
  final PrinterLocalDatasource _datasource;
  const PrinterRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<PrinterEntity>>> getAllPrinters() async {
    try {
      final list = await _datasource.getAllPrinters();
      return right(list);
    } catch (error) {
      return left(DbFailure('Gagal mengambil daftar printer: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> addPrinter(PrinterEntity printer) async {
    try {
      final model = PrinterModel.fromEntity(printer);
      await _datasource.addPrinter(model);
      return right(null);
    } catch (error) {
      return left(DbFailure('Gagal menambahkan printer: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePrinter(PrinterEntity printer) async {
    try {
      final model = PrinterModel.fromEntity(printer);
      await _datasource.updatePrinter(model);
      return right(null);
    } catch (error) {
      return left(DbFailure('Gagal memperbarui printer: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePrinter(String id) async {
    try {
      await _datasource.deletePrinter(id);
      return right(null);
    } catch (error) {
      return left(DbFailure('Gagal menghapus printer: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultPrinter(String id) async {
    try {
      await _datasource.setDefaultPrinter(id);
      return right(null);
    } catch (error) {
      return left(DbFailure('Gagal mengatur printer default: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> testPrint(PrinterEntity printer, StoreConfigEntity storeConfig) async {
    try {
      final bytes = await _buildTestReceiptBytes(printer.paperWidth, storeConfig);
      await _writeSimulatedReceipt(printer, storeConfig, 'TEST PRINT RECEIPT\nKoneksi berhasil terhubung!');
      return await _sendToPrinter(printer, bytes);
    } catch (error) {
      return left(PrinterFailure('Gagal melakukan test print: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> printReceipt(
    PrinterEntity printer,
    StoreConfigEntity storeConfig,
    TransactionEntity transaction,
  ) async {
    try {
      final bytes = await _buildReceiptBytes(transaction, storeConfig, printer.paperWidth);
      final simText = _buildReceiptTextSimulated(transaction, storeConfig, printer.paperWidth);
      await _writeSimulatedReceipt(printer, storeConfig, simText);
      return await _sendToPrinter(printer, bytes);
    } catch (error) {
      return left(PrinterFailure('Gagal mencetak struk: $error'));
    }
  }

  // ── Core Printer Communications ────────────────────────────────────────────

  Future<Either<Failure, void>> _sendToPrinter(PrinterEntity printer, List<int> bytes) async {
    // Check if the printer is a simulation / virtual printer
    if (printer.address == 'simulation' ||
        printer.address == 'dummy' ||
        printer.address.toLowerCase().contains('simulation') ||
        printer.name.toLowerCase().contains('simulasi') ||
        printer.address.startsWith('127.0.0.1')) {
      // Simulate successful printing delay
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return right(null);
    }

    if (printer.type == PrinterType.bluetooth) {
      if (!Platform.isAndroid) {
        return left(const PrinterFailure('Koneksi Bluetooth hanya didukung pada perangkat Android.'));
      }
      try {
        final bluetooth = bt.BlueThermalPrinter.instance;
        final isConnected = await bluetooth.isConnected;
        if (isConnected != true) {
          // Coba sambungkan
          final device = bt.BluetoothDevice(printer.name, printer.address);
          await bluetooth.connect(device).timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw Exception('Koneksi Bluetooth timeout'),
              );
        }
        await bluetooth.writeBytes(Uint8List.fromList(bytes));
        return right(null);
      } catch (error) {
        return left(PrinterFailure('Koneksi Bluetooth gagal: $error'));
      }
    } else {
      // WiFi Printer Connection (raw TCP Socket)
      try {
        final parts = printer.address.split(':');
        final ip = parts[0];
        final port = int.tryParse(parts[1]) ?? 9100;

        final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 10));
        socket.add(bytes);
        await socket.flush();
        await socket.close();
        return right(null);
      } catch (error) {
        return left(PrinterFailure('Koneksi ke WiFi Printer gagal: $error'));
      }
    }
  }

  // ── ESC/POS Bytes Generation ───────────────────────────────────────────────

  Future<List<int>> _buildTestReceiptBytes(int paperWidth, StoreConfigEntity config) async {
    final profile = await CapabilityProfile.load();
    final PaperSize size = paperWidth == 58 ? PaperSize.mm58 : PaperSize.mm80;
    final generator = Generator(size, profile);
    List<int> bytes = [];

    bytes += generator.reset();
    bytes += generator.text(
      config.storeName,
      styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2),
    );
    bytes += generator.text('TEST KONEKSI PRINTER', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Lebar Kertas: $paperWidth mm', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Status: Berhasil Terhubung', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(1);
    bytes += generator.text('================================', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> _buildReceiptBytes(TransactionEntity txn, StoreConfigEntity config, int paperWidth) async {
    final profile = await CapabilityProfile.load();
    final PaperSize size = paperWidth == 58 ? PaperSize.mm58 : PaperSize.mm80;
    final generator = Generator(size, profile);
    List<int> bytes = [];

    bytes += generator.reset();

    // 1. Store Header
    bytes += generator.text(
      config.storeName.toUpperCase(),
      styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2),
    );
    if (config.storeAddress != null && config.storeAddress!.trim().isNotEmpty) {
      bytes += generator.text(config.storeAddress!, styles: const PosStyles(align: PosAlign.center));
    }
    if (config.storePhone != null && config.storePhone!.trim().isNotEmpty) {
      bytes += generator.text('Telp: ${config.storePhone!}', styles: const PosStyles(align: PosAlign.center));
    }

    final sep = paperWidth == 58 ? '--------------------------------' : '------------------------------------------------';
    bytes += generator.text(sep, styles: const PosStyles(align: PosAlign.center));

    // 2. Metadata
    bytes += generator.text('Invoice: ${txn.invoiceNumber}');
    final dateStr = '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year} ${txn.createdAt.hour.toString().padLeft(2, '0')}:${txn.createdAt.minute.toString().padLeft(2, '0')}';
    bytes += generator.text('Tanggal: $dateStr');
    bytes += generator.text('Kasir: ${txn.staffName ?? txn.staffId ?? 'Staff'}');
    
    bytes += generator.text(sep, styles: const PosStyles(align: PosAlign.center));

    // 3. Items list
    // Kolom width: mm58 has 32 chars, mm80 has 42-48 chars. Let's write them cleanly.
    for (final item in txn.items) {
      bytes += generator.text(item.productName, styles: const PosStyles(bold: true));
      
      final qtyPriceStr = '${item.quantity.toStringAsFixed(0)} x ${item.sellingPrice.formatRupiah()}';
      final totalStr = item.lineTotal.formatRupiah();
      
      // Calculate right alignment spacing
      final totalCharCount = paperWidth == 58 ? 32 : 48;
      final spacesNeeded = totalCharCount - qtyPriceStr.length - totalStr.length;
      final spaceStr = spacesNeeded > 0 ? ' ' * spacesNeeded : ' ';
      
      bytes += generator.text('$qtyPriceStr$spaceStr$totalStr');

      if (item.itemDiscountAmount > 0) {
        final discStr = '  Diskon: -${item.itemDiscountAmount.formatRupiah()}';
        bytes += generator.text(discStr);
      }
    }

    bytes += generator.text(sep, styles: const PosStyles(align: PosAlign.center));

    // 4. Totals summary
    _addTotalRowBytes(generator, bytes, 'Subtotal', txn.subtotal.formatRupiah(), paperWidth);
    if (txn.discountAmount > 0) {
      _addTotalRowBytes(generator, bytes, 'Diskon Transaksi', '-${txn.discountAmount.formatRupiah()}', paperWidth);
    }
    if (txn.taxAmount > 0) {
      final taxType = txn.taxIsInclusive ? 'Inkl.' : 'Ekskl.';
      _addTotalRowBytes(generator, bytes, 'Pajak ($taxType ${txn.taxRate.toStringAsFixed(0)}%)', txn.taxAmount.formatRupiah(), paperWidth);
    }

    bytes += generator.text(sep, styles: const PosStyles(align: PosAlign.center));
    
    // Grand Total (Large & Bold)
    _addTotalRowBytes(
      generator,
      bytes,
      'TOTAL',
      txn.total.formatRupiah(),
      paperWidth,
      isBold: true,
    );

    bytes += generator.text(sep, styles: const PosStyles(align: PosAlign.center));

    // 5. Payment details
    bytes += generator.text('Metode: ${txn.paymentMethod.name.toUpperCase()}');
    if (txn.paymentMethod == PaymentMethod.cash) {
      bytes += generator.text('Bayar: ${txn.paymentReceived?.formatRupiah() ?? 'Rp 0'}');
      bytes += generator.text('Kembali: ${txn.changeAmount?.formatRupiah() ?? 'Rp 0'}');
    }
    
    if (txn.note != null && txn.note!.trim().isNotEmpty) {
      bytes += generator.text('Catatan: ${txn.note!}');
    }

    bytes += generator.text(sep, styles: const PosStyles(align: PosAlign.center));

    // 6. Footer Text
    if (config.receiptFooter != null && config.receiptFooter!.trim().isNotEmpty) {
      final lines = config.receiptFooter!.split('\n');
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          bytes += generator.text(line.trim(), styles: const PosStyles(align: PosAlign.center));
        }
      }
      bytes += generator.feed(1);
    }

    bytes += generator.text('Terima kasih telah berbelanja', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  void _addTotalRowBytes(
    Generator generator,
    List<int> bytes,
    String label,
    String value,
    int paperWidth, {
    bool isBold = false,
  }) {
    final totalCharCount = paperWidth == 58 ? 32 : 48;
    final spacesNeeded = totalCharCount - label.length - value.length;
    final spaceStr = spacesNeeded > 0 ? ' ' * spacesNeeded : ' ';
    
    bytes.addAll(
      generator.text(
        '$label$spaceStr$value',
        styles: PosStyles(bold: isBold),
      ),
    );
  }

  // ── Simulated Print File System writer ──────────────────────────────────────

  Future<void> _writeSimulatedReceipt(PrinterEntity printer, StoreConfigEntity storeConfig, String content) async {
    try {
      final buildDir = Directory('${Directory.current.path}/build');
      if (!await buildDir.exists()) {
        await buildDir.create(recursive: true);
      }

      final file = File('${buildDir.path}/simulated_receipt.txt');
      final logContent = '''
========================================
SIMULASI STRUK CETAK FISIK
========================================
Printer Target: ${printer.name} (${printer.type.name.toUpperCase()})
Alamat Printer: ${printer.address}
Lebar Kertas  : ${printer.paperWidth} mm
Waktu Cetak   : ${DateTime.now().toIso8601String()}
----------------------------------------
$content
========================================
''';
      await file.writeAsString(logContent);
    } catch (_) {
      // Siletly ignore simulation file errors to prevent crashing
    }
  }

  String _buildReceiptTextSimulated(TransactionEntity txn, StoreConfigEntity config, int paperWidth) {
    final sb = StringBuffer();
    final width = paperWidth == 58 ? 32 : 48;
    
    String centerText(String text) {
      if (text.length >= width) return text.substring(0, width);
      final padding = (width - text.length) ~/ 2;
      return '${' ' * padding}$text';
    }

    String rowText(String left, String right) {
      final spacesNeeded = width - left.length - right.length;
      final spaceStr = spacesNeeded > 0 ? ' ' * spacesNeeded : ' ';
      return '$left$spaceStr$right';
    }

    final sep = paperWidth == 58 ? '--------------------------------' : '------------------------------------------------';

    // 1. Store Header
    sb.writeln(centerText(config.storeName.toUpperCase()));
    if (config.storeAddress != null && config.storeAddress!.trim().isNotEmpty) {
      sb.writeln(centerText(config.storeAddress!));
    }
    if (config.storePhone != null && config.storePhone!.trim().isNotEmpty) {
      sb.writeln(centerText('Telp: ${config.storePhone!}'));
    }
    sb.writeln(sep);

    // 2. Metadata
    sb.writeln('Invoice: ${txn.invoiceNumber}');
    final dateStr = '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year} ${txn.createdAt.hour.toString().padLeft(2, '0')}:${txn.createdAt.minute.toString().padLeft(2, '0')}';
    sb.writeln('Tanggal: $dateStr');
    sb.writeln('Kasir: ${txn.staffName ?? txn.staffId ?? 'Staff'}');
    sb.writeln(sep);

    // 3. Items list
    for (final item in txn.items) {
      sb.writeln(item.productName);
      final qtyPriceStr = '${item.quantity.toStringAsFixed(0)} x ${item.sellingPrice.formatRupiah()}';
      final totalStr = item.lineTotal.formatRupiah();
      sb.writeln(rowText(' $qtyPriceStr', totalStr));
      if (item.itemDiscountAmount > 0) {
        sb.writeln('  Diskon: -${item.itemDiscountAmount.formatRupiah()}');
      }
    }
    sb.writeln(sep);

    // 4. Totals summary
    sb.writeln(rowText('Subtotal', txn.subtotal.formatRupiah()));
    if (txn.discountAmount > 0) {
      sb.writeln(rowText('Diskon Transaksi', '-${txn.discountAmount.formatRupiah()}'));
    }
    if (txn.taxAmount > 0) {
      final taxType = txn.taxIsInclusive ? 'Inkl.' : 'Ekskl.';
      sb.writeln(rowText('Pajak ($taxType ${txn.taxRate.toStringAsFixed(0)}%)', txn.taxAmount.formatRupiah()));
    }
    sb.writeln(sep);
    
    // Grand Total
    sb.writeln(rowText('TOTAL', txn.total.formatRupiah()));
    sb.writeln(sep);

    // 5. Payment details
    sb.writeln('Metode: ${txn.paymentMethod.name.toUpperCase()}');
    if (txn.paymentMethod == PaymentMethod.cash) {
      sb.writeln('Bayar: ${txn.paymentReceived?.formatRupiah() ?? 'Rp 0'}');
      sb.writeln('Kembali: ${txn.changeAmount?.formatRupiah() ?? 'Rp 0'}');
    }
    if (txn.note != null && txn.note!.trim().isNotEmpty) {
      sb.writeln('Catatan: ${txn.note!}');
    }
    sb.writeln(sep);

    // 6. Footer Text
    if (config.receiptFooter != null && config.receiptFooter!.trim().isNotEmpty) {
      final lines = config.receiptFooter!.split('\n');
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          sb.writeln(centerText(line.trim()));
        }
      }
      sb.writeln();
    }

    sb.writeln(centerText('Terima kasih telah berbelanja'));
    
    return sb.toString();
  }
}
