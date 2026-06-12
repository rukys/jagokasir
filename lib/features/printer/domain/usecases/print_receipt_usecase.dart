// lib/features/printer/domain/usecases/print_receipt_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../cashier/domain/entities/transaction_entity.dart';
import '../entities/printer_entity.dart';
import '../entities/store_config_entity.dart';
import '../repositories/printer_repository.dart';

class PrintReceiptUsecase {
  final PrinterRepository _repository;
  const PrintReceiptUsecase(this._repository);

  Future<Either<Failure, void>> call({
    required PrinterEntity printer,
    required StoreConfigEntity storeConfig,
    required TransactionEntity transaction,
  }) {
    return _repository.printReceipt(printer, storeConfig, transaction);
  }
}
