// lib/features/auth/domain/usecases/create_staff_usecase.dart

import 'dart:isolate';
import 'package:bcrypt/bcrypt.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class CreateStaffUsecase {
  final StaffRepository _repository;

  const CreateStaffUsecase(this._repository);

  Future<Either<Failure, StaffEntity>> call({
    required String name,
    required StaffRole role,
    required String pin,
    required String confirmPin,
  }) async {
    // 1. Validasi input
    if (name.trim().isEmpty) {
      return left(const ValidationFailure('Nama tidak boleh kosong'));
    }
    if (pin.length < 4 || pin.length > 6 || int.tryParse(pin) == null) {
      return left(const ValidationFailure('PIN harus berupa 4-6 digit angka'));
    }
    if (pin != confirmPin) {
      return left(const ValidationFailure('Konfirmasi PIN tidak cocok'));
    }

    // 2. Cek onboarding. Jika belum onboarding, paksa role ke OWNER
    final onboardingResult = await _repository.checkOnboarding();
    final isNotOnboarded = onboardingResult.fold((_) => true, (onboarded) => !onboarded);
    
    final finalRole = isNotOnboarded ? StaffRole.owner : role;

    // 3. Hash PIN
    final pinHash = await Isolate.run(() => BCrypt.hashpw(pin, BCrypt.gensalt()));

    // 4. Buat entity
    final staff = StaffEntity(
      id: UuidGenerator.generate(),
      name: name.trim(),
      role: finalRole,
      isActive: true,
      createdAt: DateTime.now(),
    );

    return _repository.createStaff(staff, pinHash);
  }
}
