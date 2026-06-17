// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getAllStaffUsecaseHash() =>
    r'3eeaefd75388c7cdf12913a13311c15e1fad493d';

/// See also [getAllStaffUsecase].
@ProviderFor(getAllStaffUsecase)
final getAllStaffUsecaseProvider =
    AutoDisposeProvider<GetAllStaffUsecase>.internal(
  getAllStaffUsecase,
  name: r'getAllStaffUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getAllStaffUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetAllStaffUsecaseRef = AutoDisposeProviderRef<GetAllStaffUsecase>;
String _$getStaffByIdUsecaseHash() =>
    r'b1a2ed8dffd53826d9bd0e973b3e07414b25ed4d';

/// See also [getStaffByIdUsecase].
@ProviderFor(getStaffByIdUsecase)
final getStaffByIdUsecaseProvider =
    AutoDisposeProvider<GetStaffByIdUsecase>.internal(
  getStaffByIdUsecase,
  name: r'getStaffByIdUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getStaffByIdUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetStaffByIdUsecaseRef = AutoDisposeProviderRef<GetStaffByIdUsecase>;
String _$updateStaffUsecaseHash() =>
    r'9b1aa7e1e82e251e6d611b6925c467db23826627';

/// See also [updateStaffUsecase].
@ProviderFor(updateStaffUsecase)
final updateStaffUsecaseProvider =
    AutoDisposeProvider<UpdateStaffUsecase>.internal(
  updateStaffUsecase,
  name: r'updateStaffUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateStaffUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UpdateStaffUsecaseRef = AutoDisposeProviderRef<UpdateStaffUsecase>;
String _$toggleStaffActiveUsecaseHash() =>
    r'dce026115101491fd8e169ede6c384d07e2b6949';

/// See also [toggleStaffActiveUsecase].
@ProviderFor(toggleStaffActiveUsecase)
final toggleStaffActiveUsecaseProvider =
    AutoDisposeProvider<ToggleStaffActiveUsecase>.internal(
  toggleStaffActiveUsecase,
  name: r'toggleStaffActiveUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$toggleStaffActiveUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ToggleStaffActiveUsecaseRef
    = AutoDisposeProviderRef<ToggleStaffActiveUsecase>;
String _$resetStaffPinUsecaseHash() =>
    r'9f64bf9da33f58f7f3919308cf24f119e2b7120c';

/// See also [resetStaffPinUsecase].
@ProviderFor(resetStaffPinUsecase)
final resetStaffPinUsecaseProvider =
    AutoDisposeProvider<ResetStaffPinUsecase>.internal(
  resetStaffPinUsecase,
  name: r'resetStaffPinUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resetStaffPinUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ResetStaffPinUsecaseRef = AutoDisposeProviderRef<ResetStaffPinUsecase>;
String _$staffListHash() => r'1678aae461b004755a0b3b78f97672a64b182af1';

/// Mengambil daftar semua staff
///
/// Copied from [staffList].
@ProviderFor(staffList)
final staffListProvider = AutoDisposeFutureProvider<List<StaffEntity>>.internal(
  staffList,
  name: r'staffListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$staffListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StaffListRef = AutoDisposeFutureProviderRef<List<StaffEntity>>;
String _$staffByIdHash() => r'932f552ad60f29badda5512078a929895f6ca5d6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Mengambil staff berdasarkan ID
///
/// Copied from [staffById].
@ProviderFor(staffById)
const staffByIdProvider = StaffByIdFamily();

/// Mengambil staff berdasarkan ID
///
/// Copied from [staffById].
class StaffByIdFamily extends Family<AsyncValue<StaffEntity>> {
  /// Mengambil staff berdasarkan ID
  ///
  /// Copied from [staffById].
  const StaffByIdFamily();

  /// Mengambil staff berdasarkan ID
  ///
  /// Copied from [staffById].
  StaffByIdProvider call(
    String id,
  ) {
    return StaffByIdProvider(
      id,
    );
  }

  @override
  StaffByIdProvider getProviderOverride(
    covariant StaffByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'staffByIdProvider';
}

/// Mengambil staff berdasarkan ID
///
/// Copied from [staffById].
class StaffByIdProvider extends AutoDisposeFutureProvider<StaffEntity> {
  /// Mengambil staff berdasarkan ID
  ///
  /// Copied from [staffById].
  StaffByIdProvider(
    String id,
  ) : this._internal(
          (ref) => staffById(
            ref as StaffByIdRef,
            id,
          ),
          from: staffByIdProvider,
          name: r'staffByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$staffByIdHash,
          dependencies: StaffByIdFamily._dependencies,
          allTransitiveDependencies: StaffByIdFamily._allTransitiveDependencies,
          id: id,
        );

  StaffByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<StaffEntity> Function(StaffByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StaffByIdProvider._internal(
        (ref) => create(ref as StaffByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StaffEntity> createElement() {
    return _StaffByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StaffByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StaffByIdRef on AutoDisposeFutureProviderRef<StaffEntity> {
  /// The parameter `id` of this provider.
  String get id;
}

class _StaffByIdProviderElement
    extends AutoDisposeFutureProviderElement<StaffEntity> with StaffByIdRef {
  _StaffByIdProviderElement(super.provider);

  @override
  String get id => (origin as StaffByIdProvider).id;
}

String _$staffNotifierHash() => r'b636e893a090d500b1a06ac859cadf0829a41979';

/// See also [StaffNotifier].
@ProviderFor(StaffNotifier)
final staffNotifierProvider =
    AutoDisposeNotifierProvider<StaffNotifier, AsyncValue<void>>.internal(
  StaffNotifier.new,
  name: r'staffNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$staffNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StaffNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
