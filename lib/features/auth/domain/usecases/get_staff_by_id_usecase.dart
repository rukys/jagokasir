// lib/features/auth/domain/usecases/get_staff_by_id_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class GetStaffByIdUsecase {
  final StaffRepository _repository;

  const GetStaffByIdUsecase(this._repository);

  Future<Either<Failure, StaffEntity>> call(String id) {
    if (id.trim().isEmpty) {
      return Future.value(left(const ValidationFailure('ID tidak boleh kosong')));
    }
    return _repository.getStaffById(id);
  }
}
