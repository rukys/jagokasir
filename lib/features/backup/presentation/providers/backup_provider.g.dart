// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$backupLocalDatasourceHash() =>
    r'894f5a4c8bb0fd92b38d3a0f091db28722a9ea1d';

/// See also [backupLocalDatasource].
@ProviderFor(backupLocalDatasource)
final backupLocalDatasourceProvider =
    AutoDisposeProvider<BackupLocalDatasource>.internal(
  backupLocalDatasource,
  name: r'backupLocalDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backupLocalDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BackupLocalDatasourceRef
    = AutoDisposeProviderRef<BackupLocalDatasource>;
String _$backupRepositoryHash() => r'28d7c47bf648cecdda7ca4637974c7dafbe40cc4';

/// See also [backupRepository].
@ProviderFor(backupRepository)
final backupRepositoryProvider = AutoDisposeProvider<BackupRepository>.internal(
  backupRepository,
  name: r'backupRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backupRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BackupRepositoryRef = AutoDisposeProviderRef<BackupRepository>;
String _$createBackupUsecaseHash() =>
    r'39bdb133f5aafc4ff1bcc05690001d8e5069c974';

/// See also [createBackupUsecase].
@ProviderFor(createBackupUsecase)
final createBackupUsecaseProvider =
    AutoDisposeProvider<CreateBackupUsecase>.internal(
  createBackupUsecase,
  name: r'createBackupUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createBackupUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CreateBackupUsecaseRef = AutoDisposeProviderRef<CreateBackupUsecase>;
String _$deleteBackupUsecaseHash() =>
    r'dfc53a9b96e2fa637c785e1258a3a2a4156d294e';

/// See also [deleteBackupUsecase].
@ProviderFor(deleteBackupUsecase)
final deleteBackupUsecaseProvider =
    AutoDisposeProvider<DeleteBackupUsecase>.internal(
  deleteBackupUsecase,
  name: r'deleteBackupUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteBackupUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeleteBackupUsecaseRef = AutoDisposeProviderRef<DeleteBackupUsecase>;
String _$getBackupHistoryUsecaseHash() =>
    r'30e6ffb4f6c6fd21a1d67b72a46211c897bb9f6c';

/// See also [getBackupHistoryUsecase].
@ProviderFor(getBackupHistoryUsecase)
final getBackupHistoryUsecaseProvider =
    AutoDisposeProvider<GetBackupHistoryUsecase>.internal(
  getBackupHistoryUsecase,
  name: r'getBackupHistoryUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getBackupHistoryUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetBackupHistoryUsecaseRef
    = AutoDisposeProviderRef<GetBackupHistoryUsecase>;
String _$restoreBackupUsecaseHash() =>
    r'6f0ed66ce168fca0148e2e7954fe25efac5d0334';

/// See also [restoreBackupUsecase].
@ProviderFor(restoreBackupUsecase)
final restoreBackupUsecaseProvider =
    AutoDisposeProvider<RestoreBackupUsecase>.internal(
  restoreBackupUsecase,
  name: r'restoreBackupUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$restoreBackupUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RestoreBackupUsecaseRef = AutoDisposeProviderRef<RestoreBackupUsecase>;
String _$shareBackupUsecaseHash() =>
    r'93312dee72ae448c0b1c05821ecb8faffdd4fdfe';

/// See also [shareBackupUsecase].
@ProviderFor(shareBackupUsecase)
final shareBackupUsecaseProvider =
    AutoDisposeProvider<ShareBackupUsecase>.internal(
  shareBackupUsecase,
  name: r'shareBackupUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shareBackupUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ShareBackupUsecaseRef = AutoDisposeProviderRef<ShareBackupUsecase>;
String _$validateBackupFileUsecaseHash() =>
    r'7ed3c7fdf57ef86543568814f9dd12a35ac85871';

/// See also [validateBackupFileUsecase].
@ProviderFor(validateBackupFileUsecase)
final validateBackupFileUsecaseProvider =
    AutoDisposeProvider<ValidateBackupFileUsecase>.internal(
  validateBackupFileUsecase,
  name: r'validateBackupFileUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$validateBackupFileUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ValidateBackupFileUsecaseRef
    = AutoDisposeProviderRef<ValidateBackupFileUsecase>;
String _$backupHistoryHash() => r'aa82875ebd7bc7d719c88caa4d0f439e3d0a48f2';

/// See also [backupHistory].
@ProviderFor(backupHistory)
final backupHistoryProvider =
    AutoDisposeFutureProvider<List<BackupHistoryEntity>>.internal(
  backupHistory,
  name: r'backupHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backupHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BackupHistoryRef
    = AutoDisposeFutureProviderRef<List<BackupHistoryEntity>>;
String _$backupNotifierHash() => r'9152434ad636a0e6936a27f4e4f0e18aa1ebf5b0';

/// See also [BackupNotifier].
@ProviderFor(BackupNotifier)
final backupNotifierProvider = AutoDisposeNotifierProvider<BackupNotifier,
    AsyncValue<BackupHistoryEntity?>>.internal(
  BackupNotifier.new,
  name: r'backupNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backupNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BackupNotifier
    = AutoDisposeNotifier<AsyncValue<BackupHistoryEntity?>>;
String _$restoreNotifierHash() => r'7de69cd39160420dff8a01a0a1c5829ede6bf769';

/// See also [RestoreNotifier].
@ProviderFor(RestoreNotifier)
final restoreNotifierProvider =
    AutoDisposeNotifierProvider<RestoreNotifier, AsyncValue<void>>.internal(
  RestoreNotifier.new,
  name: r'restoreNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$restoreNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RestoreNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$backupSettingsNotifierHash() =>
    r'7cc604045260bc0ad66c3b47bfe52f0f79fb927d';

/// See also [BackupSettingsNotifier].
@ProviderFor(BackupSettingsNotifier)
final backupSettingsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    BackupSettingsNotifier, BackupSettingsState>.internal(
  BackupSettingsNotifier.new,
  name: r'backupSettingsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backupSettingsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BackupSettingsNotifier
    = AutoDisposeAsyncNotifier<BackupSettingsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
