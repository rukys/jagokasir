// test/features/auth/change_pin_test.dart

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:pos_kasir/core/error/failures.dart';
import 'package:pos_kasir/features/auth/domain/entities/staff_entity.dart';
import 'package:pos_kasir/features/auth/domain/repositories/staff_repository.dart';
import 'package:pos_kasir/features/auth/domain/usecases/change_pin_usecase.dart';

class FakeStaffRepository implements StaffRepository {
  String pinHash = BCrypt.hashpw('123456', BCrypt.gensalt());

  @override
  Future<Either<Failure, String>> getPinHash(String id) async {
    return right(pinHash);
  }

  @override
  Future<Either<Failure, bool>> resetStaffPin(String id, String newPinHash) async {
    pinHash = newPinHash;
    return right(true);
  }

  @override
  Future<Either<Failure, bool>> checkOnboarding() => throw UnimplementedError();
  @override
  Future<Either<Failure, List<StaffEntity>>> getAllStaffs() => throw UnimplementedError();
  @override
  Future<Either<Failure, StaffEntity>> getStaffById(String id) => throw UnimplementedError();
  @override
  Future<Either<Failure, StaffEntity>> createStaff(StaffEntity staff, String pinHash) => throw UnimplementedError();
  @override
  Future<Either<Failure, StaffEntity>> updateStaff(StaffEntity staff) => throw UnimplementedError();
  @override
  Future<Either<Failure, StaffEntity>> toggleStaffActive(String id, bool active) => throw UnimplementedError();
  @override
  Future<Either<Failure, StaffEntity>> updateLastLogin(String id) => throw UnimplementedError();
  @override
  Future<Either<Failure, int>> getActiveOwnerCount() => throw UnimplementedError();
}

void main() {
  late FakeStaffRepository repository;
  late ChangePinUsecase usecase;

  setUp(() {
    repository = FakeStaffRepository();
    usecase = ChangePinUsecase(repository);
  });

  test('should successfully change pin when all inputs are valid', () async {
    final result = await usecase(
      staffId: '1',
      oldPin: '123456',
      newPin: '654321',
      confirmPin: '654321',
    );

    expect(result.isRight(), true);
    expect(result.fold((_) => false, (success) => success), true);

    // Verify repository's pin_hash was updated
    final hashResult = await repository.getPinHash('1');
    final storedHash = hashResult.fold((_) => '', (hash) => hash);
    expect(BCrypt.checkpw('654321', storedHash), true);
  });

  test('should fail with ValidationFailure when old pin is incorrect', () async {
    final result = await usecase(
      staffId: '1',
      oldPin: '111111',
      newPin: '654321',
      confirmPin: '654321',
    );

    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).message, 'PIN lama salah');
      },
      (_) => fail('should fail'),
    );
  });

  test('should fail with ValidationFailure when new pin format is invalid', () async {
    // Too short
    var result = await usecase(
      staffId: '1',
      oldPin: '123456',
      newPin: '123',
      confirmPin: '123',
    );
    expect(result.isLeft(), true);

    // Non-numeric
    result = await usecase(
      staffId: '1',
      oldPin: '123456',
      newPin: 'abcd',
      confirmPin: 'abcd',
    );
    expect(result.isLeft(), true);
  });

  test('should fail with ValidationFailure when confirm pin does not match', () async {
    final result = await usecase(
      staffId: '1',
      oldPin: '123456',
      newPin: '654321',
      confirmPin: '999999',
    );

    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).message, 'Konfirmasi PIN baru tidak cocok');
      },
      (_) => fail('should fail'),
    );
  });

  test('should fail with ValidationFailure when new pin is the same as old pin', () async {
    final result = await usecase(
      staffId: '1',
      oldPin: '123456',
      newPin: '123456',
      confirmPin: '123456',
    );

    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).message, 'PIN baru tidak boleh sama dengan PIN lama');
      },
      (_) => fail('should fail'),
    );
  });
}
