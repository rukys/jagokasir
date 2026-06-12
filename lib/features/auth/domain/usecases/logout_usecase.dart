// lib/features/auth/domain/usecases/logout_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

class LogoutUsecase {
  const LogoutUsecase();

  Future<Either<Failure, bool>> call() async {
    return const Right(true);
  }
}
