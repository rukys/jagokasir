// test/features/printer/printer_test.dart

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_kasir/core/error/failures.dart';
import 'package:pos_kasir/features/cashier/domain/entities/transaction_entity.dart';
import 'package:pos_kasir/features/cashier/domain/entities/transaction_item_entity.dart';
import 'package:pos_kasir/features/printer/data/datasources/printer_local_datasource.dart';
import 'package:pos_kasir/features/printer/data/datasources/store_config_datasource.dart';
import 'package:pos_kasir/features/printer/data/models/printer_model.dart';
import 'package:pos_kasir/features/printer/data/models/store_config_model.dart';
import 'package:pos_kasir/features/printer/data/repositories/printer_repository_impl.dart';
import 'package:pos_kasir/features/printer/data/repositories/store_config_repository_impl.dart';
import 'package:pos_kasir/features/printer/domain/entities/printer_entity.dart';
import 'package:pos_kasir/features/printer/domain/entities/store_config_entity.dart';
import 'package:pos_kasir/features/printer/domain/usecases/add_printer_usecase.dart';
import 'package:pos_kasir/features/printer/domain/usecases/update_store_config_usecase.dart';

class FakePrinterLocalDatasource extends PrinterLocalDatasource {
  final List<PrinterModel> printers = [];

  @override
  Future<List<PrinterModel>> getAllPrinters() async {
    return List.from(printers);
  }

  @override
  Future<void> addPrinter(PrinterModel printer) async {
    printers.add(printer);
  }

  @override
  Future<void> updatePrinter(PrinterModel printer) async {
    final index = printers.indexWhere((p) => p.id == printer.id);
    if (index != -1) {
      printers[index] = printer;
    }
  }

  @override
  Future<void> deletePrinter(String id) async {
    printers.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> setDefaultPrinter(String id) async {
    for (var i = 0; i < printers.length; i++) {
      final p = printers[i];
      printers[i] = PrinterModel(
        id: p.id,
        name: p.name,
        type: p.type,
        address: p.address,
        paperWidth: p.paperWidth,
        isDefault: p.id == id,
        isActive: p.isActive,
        createdAt: p.createdAt,
      );
    }
  }
}

class FakeStoreConfigDatasource extends StoreConfigDatasource {
  StoreConfigModel config = StoreConfigModel(
    id: 'store-config',
    storeName: 'Toko Saya',
    autoPrint: true,
    updatedAt: DateTime.now(),
  );

  @override
  Future<StoreConfigModel> getStoreConfig() async {
    return config;
  }

  @override
  Future<void> updateStoreConfig(StoreConfigModel config) async {
    this.config = config;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakePrinterLocalDatasource fakePrinterDb;
  late FakeStoreConfigDatasource fakeStoreConfigDb;
  late PrinterRepositoryImpl printerRepository;
  late StoreConfigRepositoryImpl storeConfigRepository;

  setUp(() {
    fakePrinterDb = FakePrinterLocalDatasource();
    fakeStoreConfigDb = FakeStoreConfigDatasource();
    printerRepository = PrinterRepositoryImpl(fakePrinterDb);
    storeConfigRepository = StoreConfigRepositoryImpl(fakeStoreConfigDb);
  });

  group('Printer Local DB CRUD & Usecases', () {
    test('addPrinter, getAllPrinters, updatePrinter, deletePrinter, set_default should execute correctly', () async {
      // 1. Check initially empty
      var listRes = await printerRepository.getAllPrinters();
      expect(listRes.isRight(), true);
      expect(listRes.getOrElse((_) => []), isEmpty);

      // 2. Add printer
      final printer = PrinterEntity(
        id: 'printer-1',
        name: 'Printer Kasir Depan',
        type: PrinterType.wifi,
        address: '192.168.1.100:9100',
        paperWidth: 58,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final addRes = await printerRepository.addPrinter(printer);
      expect(addRes.isRight(), true);

      // Check it was added
      listRes = await printerRepository.getAllPrinters();
      expect(listRes.getOrElse((_) => []), hasLength(1));
      expect(listRes.getOrElse((_) => []).first.name, 'Printer Kasir Depan');

      // 3. Update printer
      final updatedPrinter = printer.copyWith(name: 'Printer Utama');
      final updateRes = await printerRepository.updatePrinter(updatedPrinter);
      expect(updateRes.isRight(), true);

      listRes = await printerRepository.getAllPrinters();
      expect(listRes.getOrElse((_) => []).first.name, 'Printer Utama');

      // 4. Set Default Printer
      final secondPrinter = PrinterEntity(
        id: 'printer-2',
        name: 'Printer Dapur',
        type: PrinterType.bluetooth,
        address: '00:11:22:33:44:55',
        paperWidth: 80,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
      );
      await printerRepository.addPrinter(secondPrinter);
      
      final setDefaultRes = await printerRepository.setDefaultPrinter('printer-2');
      expect(setDefaultRes.isRight(), true);

      listRes = await printerRepository.getAllPrinters();
      final p1 = listRes.getOrElse((_) => []).firstWhere((p) => p.id == 'printer-1');
      final p2 = listRes.getOrElse((_) => []).firstWhere((p) => p.id == 'printer-2');
      expect(p1.isDefault, false);
      expect(p2.isDefault, true);

      // 5. Delete printer
      final deleteRes = await printerRepository.deletePrinter('printer-1');
      expect(deleteRes.isRight(), true);

      listRes = await printerRepository.getAllPrinters();
      expect(listRes.getOrElse((_) => []), hasLength(1));
      expect(listRes.getOrElse((_) => []).first.id, 'printer-2');
    });
  });

  group('AddPrinterUsecase Validations', () {
    late AddPrinterUsecase addPrinterUsecase;

    setUp(() {
      addPrinterUsecase = AddPrinterUsecase(printerRepository);
    });

    test('should fail with ValidationFailure if printer name is empty', () async {
      final printer = PrinterEntity(
        id: 'p-1',
        name: '  ',
        type: PrinterType.wifi,
        address: '192.168.1.100:9100',
        paperWidth: 58,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final res = await addPrinterUsecase(printer);
      expect(res.isLeft(), true);
      res.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have failed'),
      );
    });

    test('should fail with ValidationFailure if Bluetooth address is not a valid MAC', () async {
      final printer = PrinterEntity(
        id: 'p-1',
        name: 'Printer BT',
        type: PrinterType.bluetooth,
        address: 'invalid-mac-address',
        paperWidth: 58,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final res = await addPrinterUsecase(printer);
      expect(res.isLeft(), true);
      res.fold(
        (failure) => expect(failure.message, contains('Format alamat Bluetooth MAC tidak valid')),
        (_) => fail('Should have failed'),
      );
    });

    test('should fail with ValidationFailure if WiFi address does not contain port', () async {
      final printer = PrinterEntity(
        id: 'p-1',
        name: 'Printer WiFi',
        type: PrinterType.wifi,
        address: '192.168.1.100',
        paperWidth: 58,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final res = await addPrinterUsecase(printer);
      expect(res.isLeft(), true);
      res.fold(
        (failure) => expect(failure.message, contains('Format alamat WiFi harus berupa IP:Port')),
        (_) => fail('Should have failed'),
      );
    });

    test('should fail with ValidationFailure if WiFi IP format is invalid', () async {
      final printer = PrinterEntity(
        id: 'p-1',
        name: 'Printer WiFi',
        type: PrinterType.wifi,
        address: '192.168.1.300:9100', // 300 is invalid IP octet
        paperWidth: 58,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final res = await addPrinterUsecase(printer);
      expect(res.isLeft(), true);
      res.fold(
        (failure) => expect(failure.message, contains('Alamat IP WiFi tidak valid')),
        (_) => fail('Should have failed'),
      );
    });

    test('should fail with ValidationFailure if WiFi Port format is invalid', () async {
      final printer = PrinterEntity(
        id: 'p-1',
        name: 'Printer WiFi',
        type: PrinterType.wifi,
        address: '192.168.1.100:999999', // out of range port
        paperWidth: 58,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final res = await addPrinterUsecase(printer);
      expect(res.isLeft(), true);
      res.fold(
        (failure) => expect(failure.message, contains('Port WiFi tidak valid')),
        (_) => fail('Should have failed'),
      );
    });

    test('should succeed if validation passes', () async {
      final printer = PrinterEntity(
        id: 'p-1',
        name: 'Printer WiFi',
        type: PrinterType.wifi,
        address: '192.168.1.100:9100',
        paperWidth: 58,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final res = await addPrinterUsecase(printer);
      expect(res.isRight(), true);
    });
  });

  group('Store Config CRUD & Usecases', () {
    test('getStoreConfig and updateStoreConfig should work correctly', () async {
      final getRes = await storeConfigRepository.getStoreConfig();
      expect(getRes.isRight(), true);
      expect(getRes.getOrElse((_) => throw Exception()).storeName, 'Toko Saya');

      final newConfig = StoreConfigEntity(
        id: 'store-config',
        storeName: 'Kopi Kenangan UMKM',
        storeAddress: 'Jl. Merdeka No. 10',
        storePhone: '08123456789',
        receiptFooter: 'Terima kasih\nDatang kembali',
        autoPrint: false,
        updatedAt: DateTime.now(),
      );

      final updateRes = await storeConfigRepository.updateStoreConfig(newConfig);
      expect(updateRes.isRight(), true);

      final getUpdatedRes = await storeConfigRepository.getStoreConfig();
      expect(getUpdatedRes.isRight(), true);
      final fetched = getUpdatedRes.getOrElse((_) => throw Exception());
      expect(fetched.storeName, 'Kopi Kenangan UMKM');
      expect(fetched.storeAddress, 'Jl. Merdeka No. 10');
      expect(fetched.autoPrint, false);
    });

    test('UpdateStoreConfigUsecase should validate name is not empty', () async {
      final usecase = UpdateStoreConfigUsecase(storeConfigRepository);
      final invalidConfig = StoreConfigEntity(
        id: 'store-config',
        storeName: '  ',
        autoPrint: true,
        updatedAt: DateTime.now(),
      );

      final res = await usecase(invalidConfig);
      expect(res.isLeft(), true);
      res.fold(
        (failure) => expect(failure.message, contains('Nama toko tidak boleh kosong')),
        (_) => fail('Should have failed'),
      );
    });
  });

  group('Printing Simulation & Testing', () {
    test('testPrint on a simulated WiFi printer should succeed and write to file', () async {
      final config = StoreConfigEntity(
        id: 'store-config',
        storeName: 'Toko Simulasi',
        storeAddress: 'Alamat Virtual',
        storePhone: '12345',
        autoPrint: true,
        updatedAt: DateTime.now(),
      );

      final simPrinter = PrinterEntity(
        id: 'sim-printer-1',
        name: 'Printer Simulasi',
        type: PrinterType.wifi,
        address: '127.0.0.1:9100', // matches simulation pattern
        paperWidth: 58,
        isDefault: true,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Perform test print
      final testRes = await printerRepository.testPrint(simPrinter, config);
      testRes.fold(
        (failure) => fail('testPrint failed with message: ${failure.message}'),
        (_) => null,
      );

      // Verify that the simulated print file was created
      final simFile = File('build/simulated_receipt.txt');
      expect(await simFile.exists(), true);

      final content = await simFile.readAsString();
      expect(content, contains('SIMULASI STRUK CETAK FISIK'));
      expect(content, contains('Printer Target: Printer Simulasi'));
      expect(content, contains('TEST PRINT RECEIPT'));
    });

    test('printReceipt on a simulated Bluetooth printer should succeed and write receipt contents', () async {
      final config = StoreConfigEntity(
        id: 'store-config',
        storeName: 'Kopi Bahagia',
        storeAddress: 'Sudirman Kav 21',
        storePhone: '021-99999',
        receiptFooter: 'Silakan berkunjung kembali',
        autoPrint: true,
        updatedAt: DateTime.now(),
      );

      final simPrinter = PrinterEntity(
        id: 'sim-printer-2',
        name: 'Bluetooth Simulasi', // matches name contains 'simulasi'
        type: PrinterType.bluetooth,
        address: '00:11:22:33:44:55', // valid MAC address for usecase validation
        paperWidth: 80,
        isDefault: true,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final transaction = TransactionEntity(
        id: 'txn-123',
        invoiceNumber: 'INV/2026/0001',
        staffId: 'staff-1',
        staffName: 'Budi Kasir',
        subtotal: 50000,
        discountAmount: 5000,
        taxRate: 11,
        taxIsInclusive: false,
        taxAmount: 4950,
        total: 49950,
        paymentMethod: PaymentMethod.cash,
        paymentReceived: 50000,
        changeAmount: 50,
        status: TransactionStatus.completed,
        createdAt: DateTime(2026, 6, 11, 10, 30),
        items: [
          const TransactionItemEntity(
            id: 'item-1',
            transactionId: 'txn-123',
            productId: 'p-1',
            productName: 'Kopi Susu Gula Aren',
            productSku: 'KOPI-01',
            sellingPrice: 20000,
            quantity: 2,
            itemDiscountAmount: 0,
            lineTotal: 40000,
          ),
          const TransactionItemEntity(
            id: 'item-2',
            transactionId: 'txn-123',
            productId: 'p-2',
            productName: 'Roti Bakar Cokelat',
            productSku: 'ROTI-02',
            sellingPrice: 10000,
            quantity: 1,
            itemDiscountAmount: 0,
            lineTotal: 10000,
          ),
        ],
      );

      // Perform print receipt
      final printRes = await printerRepository.printReceipt(simPrinter, config, transaction);
      printRes.fold(
        (failure) => fail('printReceipt failed with message: ${failure.message}'),
        (_) => null,
      );

      // Verify that the simulated print file contains receipt contents
      final simFile = File('build/simulated_receipt.txt');
      expect(await simFile.exists(), true);

      final content = await simFile.readAsString();
      expect(content, contains('KOPI BAHAGIA'));
      expect(content, contains('INV/2026/0001'));
      expect(content, contains('Kopi Susu Gula Aren'));
      expect(content, contains('2 x Rp 20.000'));
      expect(content, contains('TOTAL'));
      expect(content, contains('Rp 49.950'));
      expect(content, contains('Kembali: Rp 50'));
    });
  });
}
