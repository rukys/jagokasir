// lib/features/printer/domain/usecases/delete_printer_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/printer_repository.dart';

class DeletePrinterUsecase {
  final PrinterRepository _repository;
  const DeletePrinterUsecase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    if (id.trim().isEmpty) {
      return Future.value(left(const ValidationFailure('ID printer tidak boleh kosong')));
    }
    return _repository.deletePrinter(id);
  }
}
