// lib/features/printer/domain/usecases/add_printer_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/printer_entity.dart';
import '../repositories/printer_repository.dart';

class AddPrinterUsecase {
  final PrinterRepository _repository;
  const AddPrinterUsecase(this._repository);

  Future<Either<Failure, void>> call(PrinterEntity printer) {
    if (printer.name.trim().isEmpty) {
      return Future.value(left(const ValidationFailure('Nama printer tidak boleh kosong')));
    }

    if (printer.type == PrinterType.bluetooth) {
      // Validasi MAC address: XX:XX:XX:XX:XX:XX
      final macRegExp = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
      if (!macRegExp.hasMatch(printer.address)) {
        return Future.value(left(const ValidationFailure(
          'Format alamat Bluetooth MAC tidak valid. Contoh: 00:11:22:33:FF:EE',
        ),),);
      }
    } else if (printer.type == PrinterType.wifi) {
      // Validasi format IP:Port
      final parts = printer.address.split(':');
      if (parts.length != 2) {
        return Future.value(left(const ValidationFailure(
          'Format alamat WiFi harus berupa IP:Port. Contoh: 192.168.1.100:9100',
        ),),);
      }

      final ip = parts[0];
      final portStr = parts[1];

      // Simple IP check
      final ipRegExp = RegExp(
        r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
      );
      if (!ipRegExp.hasMatch(ip)) {
        return Future.value(left(const ValidationFailure('Alamat IP WiFi tidak valid')));
      }

      final port = int.tryParse(portStr);
      if (port == null || port <= 0 || port > 65535) {
        return Future.value(left(const ValidationFailure('Port WiFi tidak valid (harus 1 - 65535)')));
      }
    }

    return _repository.addPrinter(printer);
  }
}
