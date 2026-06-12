// lib/features/printer/domain/usecases/get_all_printers_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/printer_entity.dart';
import '../repositories/printer_repository.dart';

class GetAllPrintersUsecase {
  final PrinterRepository _repository;
  const GetAllPrintersUsecase(this._repository);

  Future<Either<Failure, List<PrinterEntity>>> call() {
    return _repository.getAllPrinters();
  }
}
