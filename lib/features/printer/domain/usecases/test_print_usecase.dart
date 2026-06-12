// lib/features/printer/domain/usecases/test_print_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/printer_entity.dart';
import '../entities/store_config_entity.dart';
import '../repositories/printer_repository.dart';

class TestPrintUsecase {
  final PrinterRepository _repository;
  const TestPrintUsecase(this._repository);

  Future<Either<Failure, void>> call(PrinterEntity printer, StoreConfigEntity storeConfig) {
    return _repository.testPrint(printer, storeConfig);
  }
}
