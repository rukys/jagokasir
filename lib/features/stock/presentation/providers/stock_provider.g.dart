// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stockLocalDatasourceHash() =>
    r'22446220c727c4dcb839cb7982c5341505746786';

/// See also [stockLocalDatasource].
@ProviderFor(stockLocalDatasource)
final stockLocalDatasourceProvider =
    AutoDisposeProvider<StockLocalDatasource>.internal(
  stockLocalDatasource,
  name: r'stockLocalDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stockLocalDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StockLocalDatasourceRef = AutoDisposeProviderRef<StockLocalDatasource>;
String _$stockRepositoryHash() => r'59e7629730da85e1760d5437c7d945ab987aec47';

/// See also [stockRepository].
@ProviderFor(stockRepository)
final stockRepositoryProvider = AutoDisposeProvider<StockRepository>.internal(
  stockRepository,
  name: r'stockRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stockRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StockRepositoryRef = AutoDisposeProviderRef<StockRepository>;
String _$getAllStocksUsecaseHash() =>
    r'e93996a2b1b755083d51f5d363972c780bed47b9';

/// See also [getAllStocksUsecase].
@ProviderFor(getAllStocksUsecase)
final getAllStocksUsecaseProvider =
    AutoDisposeProvider<GetAllStocksUsecase>.internal(
  getAllStocksUsecase,
  name: r'getAllStocksUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getAllStocksUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetAllStocksUsecaseRef = AutoDisposeProviderRef<GetAllStocksUsecase>;
String _$getStockByProductUsecaseHash() =>
    r'58243b98d3491b1b1b7663bb72a278c59adb3ac0';

/// See also [getStockByProductUsecase].
@ProviderFor(getStockByProductUsecase)
final getStockByProductUsecaseProvider =
    AutoDisposeProvider<GetStockByProductUsecase>.internal(
  getStockByProductUsecase,
  name: r'getStockByProductUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getStockByProductUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetStockByProductUsecaseRef
    = AutoDisposeProviderRef<GetStockByProductUsecase>;
String _$adjustStockUsecaseHash() =>
    r'c2b7110f34c89dd996e8e375b806c3c463f72e20';

/// See also [adjustStockUsecase].
@ProviderFor(adjustStockUsecase)
final adjustStockUsecaseProvider =
    AutoDisposeProvider<AdjustStockUsecase>.internal(
  adjustStockUsecase,
  name: r'adjustStockUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adjustStockUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AdjustStockUsecaseRef = AutoDisposeProviderRef<AdjustStockUsecase>;
String _$getStockLedgerUsecaseHash() =>
    r'396431ae2882ff1635bae1e069f999e23f2780ab';

/// See also [getStockLedgerUsecase].
@ProviderFor(getStockLedgerUsecase)
final getStockLedgerUsecaseProvider =
    AutoDisposeProvider<GetStockLedgerUsecase>.internal(
  getStockLedgerUsecase,
  name: r'getStockLedgerUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getStockLedgerUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetStockLedgerUsecaseRef
    = AutoDisposeProviderRef<GetStockLedgerUsecase>;
String _$getLowStockProductsUsecaseHash() =>
    r'6ad0c56c61bf9067a2301daf6b736bf026ea8a8f';

/// See also [getLowStockProductsUsecase].
@ProviderFor(getLowStockProductsUsecase)
final getLowStockProductsUsecaseProvider =
    AutoDisposeProvider<GetLowStockProductsUsecase>.internal(
  getLowStockProductsUsecase,
  name: r'getLowStockProductsUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getLowStockProductsUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetLowStockProductsUsecaseRef
    = AutoDisposeProviderRef<GetLowStockProductsUsecase>;
String _$updateStockSettingsUsecaseHash() =>
    r'e78e94c82a78350b70af59da0f687f171b197cfe';

/// See also [updateStockSettingsUsecase].
@ProviderFor(updateStockSettingsUsecase)
final updateStockSettingsUsecaseProvider =
    AutoDisposeProvider<UpdateStockSettingsUsecase>.internal(
  updateStockSettingsUsecase,
  name: r'updateStockSettingsUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateStockSettingsUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UpdateStockSettingsUsecaseRef
    = AutoDisposeProviderRef<UpdateStockSettingsUsecase>;
String _$stockListHash() => r'd6223ec85561f46a65e2814036697515b454ee77';

/// Semua stok produk — reload saat ada invalidation.
///
/// Copied from [stockList].
@ProviderFor(stockList)
final stockListProvider = AutoDisposeFutureProvider<List<StockEntity>>.internal(
  stockList,
  name: r'stockListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$stockListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StockListRef = AutoDisposeFutureProviderRef<List<StockEntity>>;
String _$stockByProductHash() => r'721e6c9f600ca85c0d09a6208315bedfdc358850';

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

/// Stok satu produk berdasarkan productId.
///
/// Copied from [stockByProduct].
@ProviderFor(stockByProduct)
const stockByProductProvider = StockByProductFamily();

/// Stok satu produk berdasarkan productId.
///
/// Copied from [stockByProduct].
class StockByProductFamily extends Family<AsyncValue<StockEntity>> {
  /// Stok satu produk berdasarkan productId.
  ///
  /// Copied from [stockByProduct].
  const StockByProductFamily();

  /// Stok satu produk berdasarkan productId.
  ///
  /// Copied from [stockByProduct].
  StockByProductProvider call(
    String productId,
  ) {
    return StockByProductProvider(
      productId,
    );
  }

  @override
  StockByProductProvider getProviderOverride(
    covariant StockByProductProvider provider,
  ) {
    return call(
      provider.productId,
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
  String? get name => r'stockByProductProvider';
}

/// Stok satu produk berdasarkan productId.
///
/// Copied from [stockByProduct].
class StockByProductProvider extends AutoDisposeFutureProvider<StockEntity> {
  /// Stok satu produk berdasarkan productId.
  ///
  /// Copied from [stockByProduct].
  StockByProductProvider(
    String productId,
  ) : this._internal(
          (ref) => stockByProduct(
            ref as StockByProductRef,
            productId,
          ),
          from: stockByProductProvider,
          name: r'stockByProductProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$stockByProductHash,
          dependencies: StockByProductFamily._dependencies,
          allTransitiveDependencies:
              StockByProductFamily._allTransitiveDependencies,
          productId: productId,
        );

  StockByProductProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    FutureOr<StockEntity> Function(StockByProductRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StockByProductProvider._internal(
        (ref) => create(ref as StockByProductRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StockEntity> createElement() {
    return _StockByProductProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StockByProductProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StockByProductRef on AutoDisposeFutureProviderRef<StockEntity> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _StockByProductProviderElement
    extends AutoDisposeFutureProviderElement<StockEntity>
    with StockByProductRef {
  _StockByProductProviderElement(super.provider);

  @override
  String get productId => (origin as StockByProductProvider).productId;
}

String _$lowStockListHash() => r'a6879ab3f7ea3d699cee3d94365c66e1ebcd4514';

/// Produk dengan stok rendah.
///
/// Copied from [lowStockList].
@ProviderFor(lowStockList)
final lowStockListProvider =
    AutoDisposeFutureProvider<List<StockEntity>>.internal(
  lowStockList,
  name: r'lowStockListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$lowStockListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LowStockListRef = AutoDisposeFutureProviderRef<List<StockEntity>>;
String _$lowStockCountHash() => r'28f6cf76be7d50c21c94fbe181b155bc9210a7e0';

/// Jumlah produk stok rendah — untuk badge di navigasi.
///
/// Copied from [lowStockCount].
@ProviderFor(lowStockCount)
final lowStockCountProvider = AutoDisposeFutureProvider<int>.internal(
  lowStockCount,
  name: r'lowStockCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lowStockCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LowStockCountRef = AutoDisposeFutureProviderRef<int>;
String _$stockLedgerHash() => r'497f65f27f3228a10646ccd5990d4da4da920ac6';

/// Riwayat mutasi stok satu produk.
///
/// Copied from [stockLedger].
@ProviderFor(stockLedger)
const stockLedgerProvider = StockLedgerFamily();

/// Riwayat mutasi stok satu produk.
///
/// Copied from [stockLedger].
class StockLedgerFamily extends Family<AsyncValue<List<StockLedgerEntity>>> {
  /// Riwayat mutasi stok satu produk.
  ///
  /// Copied from [stockLedger].
  const StockLedgerFamily();

  /// Riwayat mutasi stok satu produk.
  ///
  /// Copied from [stockLedger].
  StockLedgerProvider call(
    String productId,
  ) {
    return StockLedgerProvider(
      productId,
    );
  }

  @override
  StockLedgerProvider getProviderOverride(
    covariant StockLedgerProvider provider,
  ) {
    return call(
      provider.productId,
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
  String? get name => r'stockLedgerProvider';
}

/// Riwayat mutasi stok satu produk.
///
/// Copied from [stockLedger].
class StockLedgerProvider
    extends AutoDisposeFutureProvider<List<StockLedgerEntity>> {
  /// Riwayat mutasi stok satu produk.
  ///
  /// Copied from [stockLedger].
  StockLedgerProvider(
    String productId,
  ) : this._internal(
          (ref) => stockLedger(
            ref as StockLedgerRef,
            productId,
          ),
          from: stockLedgerProvider,
          name: r'stockLedgerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$stockLedgerHash,
          dependencies: StockLedgerFamily._dependencies,
          allTransitiveDependencies:
              StockLedgerFamily._allTransitiveDependencies,
          productId: productId,
        );

  StockLedgerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    FutureOr<List<StockLedgerEntity>> Function(StockLedgerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StockLedgerProvider._internal(
        (ref) => create(ref as StockLedgerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<StockLedgerEntity>> createElement() {
    return _StockLedgerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StockLedgerProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StockLedgerRef on AutoDisposeFutureProviderRef<List<StockLedgerEntity>> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _StockLedgerProviderElement
    extends AutoDisposeFutureProviderElement<List<StockLedgerEntity>>
    with StockLedgerRef {
  _StockLedgerProviderElement(super.provider);

  @override
  String get productId => (origin as StockLedgerProvider).productId;
}

String _$stockAdjustmentNotifierHash() =>
    r'3e8f3731dd0008972d936ecb7ff2fc96ddd2bc05';

/// See also [StockAdjustmentNotifier].
@ProviderFor(StockAdjustmentNotifier)
final stockAdjustmentNotifierProvider = AutoDisposeNotifierProvider<
    StockAdjustmentNotifier, AsyncValue<StockEntity?>>.internal(
  StockAdjustmentNotifier.new,
  name: r'stockAdjustmentNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stockAdjustmentNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StockAdjustmentNotifier
    = AutoDisposeNotifier<AsyncValue<StockEntity?>>;
String _$stockSettingsNotifierHash() =>
    r'794e9b44322a5f21ac8d9e4cadc664b17dcb8fda';

/// See also [StockSettingsNotifier].
@ProviderFor(StockSettingsNotifier)
final stockSettingsNotifierProvider = AutoDisposeNotifierProvider<
    StockSettingsNotifier, AsyncValue<StockEntity?>>.internal(
  StockSettingsNotifier.new,
  name: r'stockSettingsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stockSettingsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StockSettingsNotifier = AutoDisposeNotifier<AsyncValue<StockEntity?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
