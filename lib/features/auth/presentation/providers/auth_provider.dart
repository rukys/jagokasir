// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/staff_local_datasource.dart';
import '../../data/repositories/staff_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../../domain/usecases/change_pin_usecase.dart';
import '../../domain/usecases/check_onboarding_usecase.dart';
import '../../domain/usecases/create_staff_usecase.dart';
import '../../domain/usecases/login_with_pin_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_provider.g.dart';

// ── Dependency Providers ────────────────────────────────────────────────────

@riverpod
StaffLocalDatasource staffLocalDatasource(Ref ref) =>
    const StaffLocalDatasource();

@riverpod
StaffRepository staffRepository(Ref ref) =>
    StaffRepositoryImpl(ref.watch(staffLocalDatasourceProvider));

@riverpod
CheckOnboardingUsecase checkOnboardingUsecase(Ref ref) =>
    CheckOnboardingUsecase(ref.watch(staffRepositoryProvider));

@riverpod
CreateStaffUsecase createStaffUsecase(Ref ref) =>
    CreateStaffUsecase(ref.watch(staffRepositoryProvider));

@riverpod
LoginWithPinUsecase loginWithPinUsecase(Ref ref) =>
    LoginWithPinUsecase(ref.watch(staffRepositoryProvider));

@riverpod
LogoutUsecase logoutUsecase(Ref ref) =>
    const LogoutUsecase();

@riverpod
ChangePinUsecase changePinUsecase(Ref ref) =>
    ChangePinUsecase(ref.watch(staffRepositoryProvider));

// ── Auth Session Notifier ───────────────────────────────────────────────────

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthSession? build() => null; // null = belum login

  void setSession(StaffEntity staff) {
    state = AuthSession(staff: staff, loginAt: DateTime.now());
  }

  void clearSession() {
    state = null;
  }

  Future<bool> login(String staffId, String pin) async {
    final usecase = ref.read(loginWithPinUsecaseProvider);
    final result = await usecase(staffId: staffId, pin: pin);
    
    return result.fold(
      (failure) {
        return false;
      },
      (staff) {
        state = AuthSession(staff: staff, loginAt: DateTime.now());
        return true;
      },
    );
  }
}

// Convenience providers
@riverpod
StaffEntity? currentStaff(CurrentStaffRef ref) {
  return ref.watch(authNotifierProvider)?.staff;
}

@riverpod
bool isLoggedIn(IsLoggedInRef ref) {
  return ref.watch(authNotifierProvider) != null;
}

final lockedStaffIdProvider = StateProvider<String?>((ref) => null);
