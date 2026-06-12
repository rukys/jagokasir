// lib/features/auth/domain/usecases/check_onboarding_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/staff_repository.dart';

class CheckOnboardingUsecase {
  final StaffRepository _repository;

  const CheckOnboardingUsecase(this._repository);

  Future<Either<Failure, bool>> call() {
    return _repository.checkOnboarding();
  }
}
