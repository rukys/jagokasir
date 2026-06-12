// lib/features/printer/presentation/providers/printer_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../cashier/domain/entities/transaction_entity.dart';
import '../../data/datasources/printer_local_datasource.dart';
import '../../data/repositories/printer_repository_impl.dart';
import '../../domain/entities/printer_entity.dart';
import '../../domain/repositories/printer_repository.dart';
import '../../domain/usecases/add_printer_usecase.dart';
import '../../domain/usecases/delete_printer_usecase.dart';
import '../../domain/usecases/get_all_printers_usecase.dart';
import '../../domain/usecases/print_receipt_usecase.dart';
import '../../domain/usecases/set_default_printer_usecase.dart';
import '../../domain/usecases/test_print_usecase.dart';
import '../../domain/usecases/update_printer_usecase.dart';
import 'store_config_provider.dart';

part 'printer_provider.g.dart';

// ── Dependency Providers ────────────────────────────────────────────────────

@riverpod
PrinterLocalDatasource printerLocalDatasource(Ref ref) {
  return const PrinterLocalDatasource();
}

@riverpod
PrinterRepository printerRepository(Ref ref) {
  return PrinterRepositoryImpl(ref.watch(printerLocalDatasourceProvider));
}

@riverpod
GetAllPrintersUsecase getAllPrintersUsecase(Ref ref) {
  return GetAllPrintersUsecase(ref.watch(printerRepositoryProvider));
}

@riverpod
AddPrinterUsecase addPrinterUsecase(Ref ref) {
  return AddPrinterUsecase(ref.watch(printerRepositoryProvider));
}

@riverpod
UpdatePrinterUsecase updatePrinterUsecase(Ref ref) {
  return UpdatePrinterUsecase(ref.watch(printerRepositoryProvider));
}

@riverpod
DeletePrinterUsecase deletePrinterUsecase(Ref ref) {
  return DeletePrinterUsecase(ref.watch(printerRepositoryProvider));
}

@riverpod
SetDefaultPrinterUsecase setDefaultPrinterUsecase(Ref ref) {
  return SetDefaultPrinterUsecase(ref.watch(printerRepositoryProvider));
}

@riverpod
TestPrintUsecase testPrintUsecase(Ref ref) {
  return TestPrintUsecase(ref.watch(printerRepositoryProvider));
}

@riverpod
PrintReceiptUsecase printReceiptUsecase(Ref ref) {
  return PrintReceiptUsecase(ref.watch(printerRepositoryProvider));
}

// ── Data Providers ──────────────────────────────────────────────────────────

@riverpod
Future<List<PrinterEntity>> printerList(Ref ref) async {
  final usecase = ref.watch(getAllPrintersUsecaseProvider);
  final result = await usecase();
  return result.fold(
    (failure) => throw failure,
    (list) => list,
  );
}

@riverpod
Future<PrinterEntity?> defaultPrinter(Ref ref) async {
  final list = await ref.watch(printerListProvider.future);
  try {
    return list.firstWhere((p) => p.isDefault && p.isActive);
  } catch (_) {
    return null;
  }
}

// ── Print Notifier ──────────────────────────────────────────────────────────

@riverpod
class PrintNotifier extends _$PrintNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> printReceipt(TransactionEntity transaction) async {
    state = const AsyncLoading();

    final defaultPrinter = await ref.read(defaultPrinterProvider.future);
    if (defaultPrinter == null) {
      state = AsyncError(
        Exception('Belum ada printer default yang dikonfigurasi dan aktif.'),
        StackTrace.current,
      );
      return false;
    }

    final storeConfig = await ref.read(storeConfigProvider.future);
    final usecase = ref.read(printReceiptUsecaseProvider);
    final result = await usecase(
      printer: defaultPrinter,
      storeConfig: storeConfig,
      transaction: transaction,
    );

    return result.fold(
      (failure) {
        state = AsyncError(Exception(failure.message), StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> triggerTestPrint(PrinterEntity printer) async {
    state = const AsyncLoading();
    final storeConfig = await ref.read(storeConfigProvider.future);
    final usecase = ref.read(testPrintUsecaseProvider);
    final result = await usecase(printer, storeConfig);

    return result.fold(
      (failure) {
        state = AsyncError(Exception(failure.message), StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}

// ── CRUD Notifier ───────────────────────────────────────────────────────────

@riverpod
class PrinterMaintenanceNotifier extends _$PrinterMaintenanceNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> add(String name, PrinterType type, String address, int paperWidth, bool isDefault) async {
    state = const AsyncLoading();
    final usecase = ref.read(addPrinterUsecaseProvider);
    
    final printer = PrinterEntity(
      id: const Uuid().v4(),
      name: name,
      type: type,
      address: address,
      paperWidth: paperWidth,
      isDefault: isDefault,
      isActive: true,
      createdAt: DateTime.now(),
    );

    final result = await usecase(printer);
    return result.fold(
      (failure) {
        state = AsyncError(Exception(failure.message), StackTrace.current);
        return false;
      },
      (_) {
        ref.invalidate(printerListProvider);
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> update(PrinterEntity printer) async {
    state = const AsyncLoading();
    final usecase = ref.read(updatePrinterUsecaseProvider);

    final result = await usecase(printer);
    return result.fold(
      (failure) {
        state = AsyncError(Exception(failure.message), StackTrace.current);
        return false;
      },
      (_) {
        ref.invalidate(printerListProvider);
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    final usecase = ref.read(deletePrinterUsecaseProvider);

    final result = await usecase(id);
    return result.fold(
      (failure) {
        state = AsyncError(Exception(failure.message), StackTrace.current);
        return false;
      },
      (_) {
        ref.invalidate(printerListProvider);
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> makeDefault(String id) async {
    state = const AsyncLoading();
    final usecase = ref.read(setDefaultPrinterUsecaseProvider);

    final result = await usecase(id);
    return result.fold(
      (failure) {
        state = AsyncError(Exception(failure.message), StackTrace.current);
        return false;
      },
      (_) {
        ref.invalidate(printerListProvider);
        state = const AsyncData(null);
        return true;
      },
    );
  }
}
