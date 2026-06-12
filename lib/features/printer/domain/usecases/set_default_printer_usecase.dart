// lib/features/printer/domain/usecases/set_default_printer_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/printer_repository.dart';

class SetDefaultPrinterUsecase {
  final PrinterRepository _repository;
  const SetDefaultPrinterUsecase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    if (id.trim().isEmpty) {
      return Future.value(left(const ValidationFailure('ID printer tidak boleh kosong')));
    }
    return _repository.setDefaultPrinter(id);
  }
}
