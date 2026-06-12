// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionLocalDatasourceHash() =>
    r'09013b214f906b0dbde639785d874742b213a8e9';

/// See also [transactionLocalDatasource].
@ProviderFor(transactionLocalDatasource)
final transactionLocalDatasourceProvider =
    AutoDisposeProvider<TransactionLocalDatasource>.internal(
  transactionLocalDatasource,
  name: r'transactionLocalDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionLocalDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TransactionLocalDatasourceRef
    = AutoDisposeProviderRef<TransactionLocalDatasource>;
String _$transactionRepositoryHash() =>
    r'6ef64d6c0ffc4f424daaa2bad1449e1ba2b263e2';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider =
    AutoDisposeProvider<TransactionRepository>.internal(
  transactionRepository,
  name: r'transactionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TransactionRepositoryRef
    = AutoDisposeProviderRef<TransactionRepository>;
String _$getDailyInvoiceCountUsecaseHash() =>
    r'd24ff19818de6822ee49285a5a38ca55fdd111d7';

/// See also [getDailyInvoiceCountUsecase].
@ProviderFor(getDailyInvoiceCountUsecase)
final getDailyInvoiceCountUsecaseProvider =
    AutoDisposeProvider<GetDailyInvoiceCountUsecase>.internal(
  getDailyInvoiceCountUsecase,
  name: r'getDailyInvoiceCountUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getDailyInvoiceCountUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetDailyInvoiceCountUsecaseRef
    = AutoDisposeProviderRef<GetDailyInvoiceCountUsecase>;
String _$checkoutUsecaseHash() => r'ea1bfb3dfba2bca2372be2f119b796fcc2c13a63';

/// See also [checkoutUsecase].
@ProviderFor(checkoutUsecase)
final checkoutUsecaseProvider = AutoDisposeProvider<CheckoutUsecase>.internal(
  checkoutUsecase,
  name: r'checkoutUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$checkoutUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CheckoutUsecaseRef = AutoDisposeProviderRef<CheckoutUsecase>;
String _$voidTransactionUsecaseHash() =>
    r'bd30466ae943593e1a6d24fad98d6bd910cc6959';

/// See also [voidTransactionUsecase].
@ProviderFor(voidTransactionUsecase)
final voidTransactionUsecaseProvider =
    AutoDisposeProvider<VoidTransactionUsecase>.internal(
  voidTransactionUsecase,
  name: r'voidTransactionUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$voidTransactionUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef VoidTransactionUsecaseRef
    = AutoDisposeProviderRef<VoidTransactionUsecase>;
String _$getTransactionByIdUsecaseHash() =>
    r'd7772d536e75c610bf510a7215bbd8e4602ae05e';

/// See also [getTransactionByIdUsecase].
@ProviderFor(getTransactionByIdUsecase)
final getTransactionByIdUsecaseProvider =
    AutoDisposeProvider<GetTransactionByIdUsecase>.internal(
  getTransactionByIdUsecase,
  name: r'getTransactionByIdUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getTransactionByIdUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetTransactionByIdUsecaseRef
    = AutoDisposeProviderRef<GetTransactionByIdUsecase>;
String _$getTransactionListUsecaseHash() =>
    r'd1674f81a47c851d967b5ed13cce985dc75b6e30';

/// See also [getTransactionListUsecase].
@ProviderFor(getTransactionListUsecase)
final getTransactionListUsecaseProvider =
    AutoDisposeProvider<GetTransactionListUsecase>.internal(
  getTransactionListUsecase,
  name: r'getTransactionListUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getTransactionListUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetTransactionListUsecaseRef
    = AutoDisposeProviderRef<GetTransactionListUsecase>;
String _$transactionListHash() => r'f004edd0d8793a9b6da6e1e17c91c1511babf643';

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

/// Provider untuk mengambil riwayat transaksi terfilter
///
/// Copied from [transactionList].
@ProviderFor(transactionList)
const transactionListProvider = TransactionListFamily();

/// Provider untuk mengambil riwayat transaksi terfilter
///
/// Copied from [transactionList].
class TransactionListFamily
    extends Family<AsyncValue<List<TransactionEntity>>> {
  /// Provider untuk mengambil riwayat transaksi terfilter
  ///
  /// Copied from [transactionList].
  const TransactionListFamily();

  /// Provider untuk mengambil riwayat transaksi terfilter
  ///
  /// Copied from [transactionList].
  TransactionListProvider call({
    TransactionStatus? status,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TransactionListProvider(
      status: status,
      query: query,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  TransactionListProvider getProviderOverride(
    covariant TransactionListProvider provider,
  ) {
    return call(
      status: provider.status,
      query: provider.query,
      startDate: provider.startDate,
      endDate: provider.endDate,
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
  String? get name => r'transactionListProvider';
}

/// Provider untuk mengambil riwayat transaksi terfilter
///
/// Copied from [transactionList].
class TransactionListProvider
    extends AutoDisposeFutureProvider<List<TransactionEntity>> {
  /// Provider untuk mengambil riwayat transaksi terfilter
  ///
  /// Copied from [transactionList].
  TransactionListProvider({
    TransactionStatus? status,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
          (ref) => transactionList(
            ref as TransactionListRef,
            status: status,
            query: query,
            startDate: startDate,
            endDate: endDate,
          ),
          from: transactionListProvider,
          name: r'transactionListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$transactionListHash,
          dependencies: TransactionListFamily._dependencies,
          allTransitiveDependencies:
              TransactionListFamily._allTransitiveDependencies,
          status: status,
          query: query,
          startDate: startDate,
          endDate: endDate,
        );

  TransactionListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
    required this.query,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final TransactionStatus? status;
  final String? query;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<List<TransactionEntity>> Function(TransactionListRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionListProvider._internal(
        (ref) => create(ref as TransactionListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
        query: query,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TransactionEntity>> createElement() {
    return _TransactionListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionListProvider &&
        other.status == status &&
        other.query == query &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TransactionListRef
    on AutoDisposeFutureProviderRef<List<TransactionEntity>> {
  /// The parameter `status` of this provider.
  TransactionStatus? get status;

  /// The parameter `query` of this provider.
  String? get query;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _TransactionListProviderElement
    extends AutoDisposeFutureProviderElement<List<TransactionEntity>>
    with TransactionListRef {
  _TransactionListProviderElement(super.provider);

  @override
  TransactionStatus? get status => (origin as TransactionListProvider).status;
  @override
  String? get query => (origin as TransactionListProvider).query;
  @override
  DateTime? get startDate => (origin as TransactionListProvider).startDate;
  @override
  DateTime? get endDate => (origin as TransactionListProvider).endDate;
}

String _$transactionDetailHash() => r'f2760d4f44041b99ab81d61680ed2f9a69837b63';

/// Provider untuk mengambil single transaksi berdasarkan ID
///
/// Copied from [transactionDetail].
@ProviderFor(transactionDetail)
const transactionDetailProvider = TransactionDetailFamily();

/// Provider untuk mengambil single transaksi berdasarkan ID
///
/// Copied from [transactionDetail].
class TransactionDetailFamily extends Family<AsyncValue<TransactionEntity>> {
  /// Provider untuk mengambil single transaksi berdasarkan ID
  ///
  /// Copied from [transactionDetail].
  const TransactionDetailFamily();

  /// Provider untuk mengambil single transaksi berdasarkan ID
  ///
  /// Copied from [transactionDetail].
  TransactionDetailProvider call(
    String id,
  ) {
    return TransactionDetailProvider(
      id,
    );
  }

  @override
  TransactionDetailProvider getProviderOverride(
    covariant TransactionDetailProvider provider,
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
  String? get name => r'transactionDetailProvider';
}

/// Provider untuk mengambil single transaksi berdasarkan ID
///
/// Copied from [transactionDetail].
class TransactionDetailProvider
    extends AutoDisposeFutureProvider<TransactionEntity> {
  /// Provider untuk mengambil single transaksi berdasarkan ID
  ///
  /// Copied from [transactionDetail].
  TransactionDetailProvider(
    String id,
  ) : this._internal(
          (ref) => transactionDetail(
            ref as TransactionDetailRef,
            id,
          ),
          from: transactionDetailProvider,
          name: r'transactionDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$transactionDetailHash,
          dependencies: TransactionDetailFamily._dependencies,
          allTransitiveDependencies:
              TransactionDetailFamily._allTransitiveDependencies,
          id: id,
        );

  TransactionDetailProvider._internal(
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
    FutureOr<TransactionEntity> Function(TransactionDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionDetailProvider._internal(
        (ref) => create(ref as TransactionDetailRef),
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
  AutoDisposeFutureProviderElement<TransactionEntity> createElement() {
    return _TransactionDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TransactionDetailRef on AutoDisposeFutureProviderRef<TransactionEntity> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TransactionDetailProviderElement
    extends AutoDisposeFutureProviderElement<TransactionEntity>
    with TransactionDetailRef {
  _TransactionDetailProviderElement(super.provider);

  @override
  String get id => (origin as TransactionDetailProvider).id;
}

String _$checkoutNotifierHash() => r'56b250d6962d9934d3c70e4377d5c92e8c7d638e';

/// See also [CheckoutNotifier].
@ProviderFor(CheckoutNotifier)
final checkoutNotifierProvider = AutoDisposeNotifierProvider<CheckoutNotifier,
    AsyncValue<TransactionEntity?>>.internal(
  CheckoutNotifier.new,
  name: r'checkoutNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$checkoutNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CheckoutNotifier
    = AutoDisposeNotifier<AsyncValue<TransactionEntity?>>;
String _$voidNotifierHash() => r'85dabe17a677a5f31f1ea8c77612d11c9d3a52f7';

/// See also [VoidNotifier].
@ProviderFor(VoidNotifier)
final voidNotifierProvider =
    AutoDisposeNotifierProvider<VoidNotifier, AsyncValue<void>>.internal(
  VoidNotifier.new,
  name: r'voidNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$voidNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VoidNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
