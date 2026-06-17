// lib/features/auth/presentation/providers/staff_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/staff_entity.dart';
import '../../domain/usecases/get_all_staff_usecase.dart';
import '../../domain/usecases/get_staff_by_id_usecase.dart';
import '../../domain/usecases/reset_staff_pin_usecase.dart';
import '../../domain/usecases/toggle_staff_active_usecase.dart';
import '../../domain/usecases/update_staff_usecase.dart';
import 'auth_provider.dart';

part 'staff_provider.g.dart';

// ── Dependency Providers ────────────────────────────────────────────────────

@riverpod
GetAllStaffUsecase getAllStaffUsecase(Ref ref) =>
    GetAllStaffUsecase(ref.watch(staffRepositoryProvider));

@riverpod
GetStaffByIdUsecase getStaffByIdUsecase(Ref ref) =>
    GetStaffByIdUsecase(ref.watch(staffRepositoryProvider));

@riverpod
UpdateStaffUsecase updateStaffUsecase(Ref ref) =>
    UpdateStaffUsecase(ref.watch(staffRepositoryProvider));

@riverpod
ToggleStaffActiveUsecase toggleStaffActiveUsecase(Ref ref) =>
    ToggleStaffActiveUsecase(ref.watch(staffRepositoryProvider));

@riverpod
ResetStaffPinUsecase resetStaffPinUsecase(Ref ref) =>
    ResetStaffPinUsecase(ref.watch(staffRepositoryProvider));

// ── Data Providers ──────────────────────────────────────────────────────────

/// Mengambil daftar semua staff
@riverpod
Future<List<StaffEntity>> staffList(Ref ref) async {
  final usecase = ref.watch(getAllStaffUsecaseProvider);
  final result = await usecase();
  return result.fold((failure) => throw failure, (resultList) => resultList);
}

/// Mengambil staff berdasarkan ID
@riverpod
Future<StaffEntity> staffById(Ref ref, String id) async {
  final usecase = ref.watch(getStaffByIdUsecaseProvider);
  final result = await usecase(id);
  return result.fold((f) => throw f, (staff) => staff);
}

// ── Notifiers ───────────────────────────────────────────────────────────────

@riverpod
class StaffNotifier extends _$StaffNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create({
    required String name,
    required StaffRole role,
    required String pin,
    required String confirmPin,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(createStaffUsecaseProvider);
    final result = await usecase(
      name: name,
      role: role,
      pin: pin,
      confirmPin: confirmPin,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (staff) {
        state = const AsyncData(null);
        ref.invalidate(staffListProvider);
        return true;
      },
    );
  }

  Future<bool> update({
    required String id,
    required String name,
    required StaffRole role,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(updateStaffUsecaseProvider);
    final result = await usecase(
      id: id,
      name: name,
      role: role,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (staff) {
        state = const AsyncData(null);
        ref.invalidate(staffListProvider);
        ref.invalidate(staffByIdProvider(id));
        // Jika staff yang diupdate adalah staff aktif saat ini, update session-nya
        final current = ref.read(currentStaffProvider);
        if (current != null && current.id == id) {
          ref.read(authNotifierProvider.notifier).setSession(staff);
        }
        return true;
      },
    );
  }

  Future<bool> toggleActive({
    required String id,
    required bool active,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(toggleStaffActiveUsecaseProvider);
    final result = await usecase(
      id: id,
      active: active,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (staff) {
        state = const AsyncData(null);
        ref.invalidate(staffListProvider);
        ref.invalidate(staffByIdProvider(id));
        return true;
      },
    );
  }

  Future<bool> resetPin({
    required String targetStaffId,
    required String newPin,
    required String confirmPin,
  }) async {
    state = const AsyncLoading();
    final current = ref.read(currentStaffProvider);
    if (current == null) {
      state = AsyncError(Exception('Tidak ada staff login'), StackTrace.current);
      return false;
    }

    final usecase = ref.read(resetStaffPinUsecaseProvider);
    final result = await usecase(
      currentUserRole: current.role,
      targetStaffId: targetStaffId,
      newPin: newPin,
      confirmPin: confirmPin,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (success) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> changePin({
    required String staffId,
    required String oldPin,
    required String newPin,
    required String confirmPin,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(changePinUsecaseProvider);
    final result = await usecase(
      staffId: staffId,
      oldPin: oldPin,
      newPin: newPin,
      confirmPin: confirmPin,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (success) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}
