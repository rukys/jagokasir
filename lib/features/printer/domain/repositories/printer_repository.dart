// lib/features/printer/domain/repositories/printer_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../cashier/domain/entities/transaction_entity.dart';
import '../entities/printer_entity.dart';
import '../entities/store_config_entity.dart';

abstract interface class PrinterRepository {
  Future<Either<Failure, List<PrinterEntity>>> getAllPrinters();
  Future<Either<Failure, void>> addPrinter(PrinterEntity printer);
  Future<Either<Failure, void>> updatePrinter(PrinterEntity printer);
  Future<Either<Failure, void>> deletePrinter(String id);
  Future<Either<Failure, void>> setDefaultPrinter(String id);
  Future<Either<Failure, void>> testPrint(PrinterEntity printer, StoreConfigEntity storeConfig);
  Future<Either<Failure, void>> printReceipt(
    PrinterEntity printer,
    StoreConfigEntity storeConfig,
    TransactionEntity transaction,
  );
}
