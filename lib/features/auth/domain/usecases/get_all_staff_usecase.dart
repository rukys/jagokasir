// lib/features/auth/domain/usecases/get_all_staff_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class GetAllStaffUsecase {
  final StaffRepository _repository;

  const GetAllStaffUsecase(this._repository);

  Future<Either<Failure, List<StaffEntity>>> call() {
    return _repository.getAllStaffs();
  }
}
