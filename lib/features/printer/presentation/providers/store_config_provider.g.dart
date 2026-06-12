// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storeConfigDatasourceHash() =>
    r'bfcaefd85801843da3901dea5708d1a1fd0b5803';

/// See also [storeConfigDatasource].
@ProviderFor(storeConfigDatasource)
final storeConfigDatasourceProvider =
    AutoDisposeProvider<StoreConfigDatasource>.internal(
  storeConfigDatasource,
  name: r'storeConfigDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storeConfigDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StoreConfigDatasourceRef
    = AutoDisposeProviderRef<StoreConfigDatasource>;
String _$storeConfigRepositoryHash() =>
    r'f0757eb6f660737dac63862faec7d98856a10e3d';

/// See also [storeConfigRepository].
@ProviderFor(storeConfigRepository)
final storeConfigRepositoryProvider =
    AutoDisposeProvider<StoreConfigRepository>.internal(
  storeConfigRepository,
  name: r'storeConfigRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storeConfigRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StoreConfigRepositoryRef
    = AutoDisposeProviderRef<StoreConfigRepository>;
String _$getStoreConfigUsecaseHash() =>
    r'2665864b58f3eb71d6eb3bab65ad9cd00ae20777';

/// See also [getStoreConfigUsecase].
@ProviderFor(getStoreConfigUsecase)
final getStoreConfigUsecaseProvider =
    AutoDisposeProvider<GetStoreConfigUsecase>.internal(
  getStoreConfigUsecase,
  name: r'getStoreConfigUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getStoreConfigUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetStoreConfigUsecaseRef
    = AutoDisposeProviderRef<GetStoreConfigUsecase>;
String _$updateStoreConfigUsecaseHash() =>
    r'8100dc3844c2f6187307a3ca9cd3263a4a649f9f';

/// See also [updateStoreConfigUsecase].
@ProviderFor(updateStoreConfigUsecase)
final updateStoreConfigUsecaseProvider =
    AutoDisposeProvider<UpdateStoreConfigUsecase>.internal(
  updateStoreConfigUsecase,
  name: r'updateStoreConfigUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateStoreConfigUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UpdateStoreConfigUsecaseRef
    = AutoDisposeProviderRef<UpdateStoreConfigUsecase>;
String _$storeConfigHash() => r'573aa744f3b4e90231cce7a83758f23a05155bd5';

/// See also [storeConfig].
@ProviderFor(storeConfig)
final storeConfigProvider =
    AutoDisposeFutureProvider<StoreConfigEntity>.internal(
  storeConfig,
  name: r'storeConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$storeConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StoreConfigRef = AutoDisposeFutureProviderRef<StoreConfigEntity>;
String _$storeConfigMaintenanceHash() =>
    r'7d2854777c88b8181504d392b1d504776a5e62f7';

/// See also [StoreConfigMaintenance].
@ProviderFor(StoreConfigMaintenance)
final storeConfigMaintenanceProvider = AutoDisposeNotifierProvider<
    StoreConfigMaintenance, AsyncValue<void>>.internal(
  StoreConfigMaintenance.new,
  name: r'storeConfigMaintenanceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storeConfigMaintenanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StoreConfigMaintenance = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
