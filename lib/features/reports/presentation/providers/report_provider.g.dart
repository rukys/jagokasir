// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportLocalDatasourceHash() =>
    r'2baf813609a05d46b5287144d61215a3b797d65c';

/// See also [reportLocalDatasource].
@ProviderFor(reportLocalDatasource)
final reportLocalDatasourceProvider =
    AutoDisposeProvider<ReportLocalDatasource>.internal(
  reportLocalDatasource,
  name: r'reportLocalDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportLocalDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ReportLocalDatasourceRef
    = AutoDisposeProviderRef<ReportLocalDatasource>;
String _$reportRepositoryHash() => r'7ce871f9d7b0ba6e31a17a98ada5d7e2afbca7e1';

/// See also [reportRepository].
@ProviderFor(reportRepository)
final reportRepositoryProvider = AutoDisposeProvider<ReportRepository>.internal(
  reportRepository,
  name: r'reportRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ReportRepositoryRef = AutoDisposeProviderRef<ReportRepository>;
String _$getSalesSummaryUsecaseHash() =>
    r'386a94842bc81ca16ebd605e3cd2bd9c676b89fc';

/// See also [getSalesSummaryUsecase].
@ProviderFor(getSalesSummaryUsecase)
final getSalesSummaryUsecaseProvider =
    AutoDisposeProvider<GetSalesSummaryUsecase>.internal(
  getSalesSummaryUsecase,
  name: r'getSalesSummaryUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getSalesSummaryUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetSalesSummaryUsecaseRef
    = AutoDisposeProviderRef<GetSalesSummaryUsecase>;
String _$getProductPerformanceUsecaseHash() =>
    r'8aa1ebbd775e66b91f5142b2f321fe52b9dfc2a3';

/// See also [getProductPerformanceUsecase].
@ProviderFor(getProductPerformanceUsecase)
final getProductPerformanceUsecaseProvider =
    AutoDisposeProvider<GetProductPerformanceUsecase>.internal(
  getProductPerformanceUsecase,
  name: r'getProductPerformanceUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getProductPerformanceUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetProductPerformanceUsecaseRef
    = AutoDisposeProviderRef<GetProductPerformanceUsecase>;
String _$getCategoryReportUsecaseHash() =>
    r'5c0f329dae8bf5f77dc606502a5a313164787ca1';

/// See also [getCategoryReportUsecase].
@ProviderFor(getCategoryReportUsecase)
final getCategoryReportUsecaseProvider =
    AutoDisposeProvider<GetCategoryReportUsecase>.internal(
  getCategoryReportUsecase,
  name: r'getCategoryReportUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getCategoryReportUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetCategoryReportUsecaseRef
    = AutoDisposeProviderRef<GetCategoryReportUsecase>;
String _$getDailySalesTrendUsecaseHash() =>
    r'62b446a5367d51a38b7bd4c820e99bf4a21b5fcb';

/// See also [getDailySalesTrendUsecase].
@ProviderFor(getDailySalesTrendUsecase)
final getDailySalesTrendUsecaseProvider =
    AutoDisposeProvider<GetDailySalesTrendUsecase>.internal(
  getDailySalesTrendUsecase,
  name: r'getDailySalesTrendUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getDailySalesTrendUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetDailySalesTrendUsecaseRef
    = AutoDisposeProviderRef<GetDailySalesTrendUsecase>;
String _$getProfitReportUsecaseHash() =>
    r'3bef384fad1e2027509434e3a982b5a0e364f7a9';

/// See also [getProfitReportUsecase].
@ProviderFor(getProfitReportUsecase)
final getProfitReportUsecaseProvider =
    AutoDisposeProvider<GetProfitReportUsecase>.internal(
  getProfitReportUsecase,
  name: r'getProfitReportUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getProfitReportUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetProfitReportUsecaseRef
    = AutoDisposeProviderRef<GetProfitReportUsecase>;
String _$exportReportUsecaseHash() =>
    r'90260e47c883f35187257bda0b22bd4539ed3f6d';

/// See also [exportReportUsecase].
@ProviderFor(exportReportUsecase)
final exportReportUsecaseProvider =
    AutoDisposeProvider<ExportReportUsecase>.internal(
  exportReportUsecase,
  name: r'exportReportUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exportReportUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ExportReportUsecaseRef = AutoDisposeProviderRef<ExportReportUsecase>;
String _$salesSummaryHash() => r'ffff8f651bddda67749979d33eccbaa310006cb7';

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

/// See also [salesSummary].
@ProviderFor(salesSummary)
const salesSummaryProvider = SalesSummaryFamily();

/// See also [salesSummary].
class SalesSummaryFamily extends Family<AsyncValue<SalesSummaryEntity>> {
  /// See also [salesSummary].
  const SalesSummaryFamily();

  /// See also [salesSummary].
  SalesSummaryProvider call(
    DateRange period,
  ) {
    return SalesSummaryProvider(
      period,
    );
  }

  @override
  SalesSummaryProvider getProviderOverride(
    covariant SalesSummaryProvider provider,
  ) {
    return call(
      provider.period,
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
  String? get name => r'salesSummaryProvider';
}

/// See also [salesSummary].
class SalesSummaryProvider
    extends AutoDisposeFutureProvider<SalesSummaryEntity> {
  /// See also [salesSummary].
  SalesSummaryProvider(
    DateRange period,
  ) : this._internal(
          (ref) => salesSummary(
            ref as SalesSummaryRef,
            period,
          ),
          from: salesSummaryProvider,
          name: r'salesSummaryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$salesSummaryHash,
          dependencies: SalesSummaryFamily._dependencies,
          allTransitiveDependencies:
              SalesSummaryFamily._allTransitiveDependencies,
          period: period,
        );

  SalesSummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final DateRange period;

  @override
  Override overrideWith(
    FutureOr<SalesSummaryEntity> Function(SalesSummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SalesSummaryProvider._internal(
        (ref) => create(ref as SalesSummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SalesSummaryEntity> createElement() {
    return _SalesSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SalesSummaryProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SalesSummaryRef on AutoDisposeFutureProviderRef<SalesSummaryEntity> {
  /// The parameter `period` of this provider.
  DateRange get period;
}

class _SalesSummaryProviderElement
    extends AutoDisposeFutureProviderElement<SalesSummaryEntity>
    with SalesSummaryRef {
  _SalesSummaryProviderElement(super.provider);

  @override
  DateRange get period => (origin as SalesSummaryProvider).period;
}

String _$dailyTrendHash() => r'550c985a655918c13bc2e96e6384149aa96ca85a';

/// See also [dailyTrend].
@ProviderFor(dailyTrend)
const dailyTrendProvider = DailyTrendFamily();

/// See also [dailyTrend].
class DailyTrendFamily extends Family<AsyncValue<List<DailySalesEntity>>> {
  /// See also [dailyTrend].
  const DailyTrendFamily();

  /// See also [dailyTrend].
  DailyTrendProvider call(
    DateRange period,
  ) {
    return DailyTrendProvider(
      period,
    );
  }

  @override
  DailyTrendProvider getProviderOverride(
    covariant DailyTrendProvider provider,
  ) {
    return call(
      provider.period,
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
  String? get name => r'dailyTrendProvider';
}

/// See also [dailyTrend].
class DailyTrendProvider
    extends AutoDisposeFutureProvider<List<DailySalesEntity>> {
  /// See also [dailyTrend].
  DailyTrendProvider(
    DateRange period,
  ) : this._internal(
          (ref) => dailyTrend(
            ref as DailyTrendRef,
            period,
          ),
          from: dailyTrendProvider,
          name: r'dailyTrendProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailyTrendHash,
          dependencies: DailyTrendFamily._dependencies,
          allTransitiveDependencies:
              DailyTrendFamily._allTransitiveDependencies,
          period: period,
        );

  DailyTrendProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final DateRange period;

  @override
  Override overrideWith(
    FutureOr<List<DailySalesEntity>> Function(DailyTrendRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailyTrendProvider._internal(
        (ref) => create(ref as DailyTrendRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<DailySalesEntity>> createElement() {
    return _DailyTrendProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyTrendProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DailyTrendRef on AutoDisposeFutureProviderRef<List<DailySalesEntity>> {
  /// The parameter `period` of this provider.
  DateRange get period;
}

class _DailyTrendProviderElement
    extends AutoDisposeFutureProviderElement<List<DailySalesEntity>>
    with DailyTrendRef {
  _DailyTrendProviderElement(super.provider);

  @override
  DateRange get period => (origin as DailyTrendProvider).period;
}

String _$productPerformanceHash() =>
    r'b6126f0e27c2f34bfed19f98431aa74541b6d3c8';

/// See also [productPerformance].
@ProviderFor(productPerformance)
const productPerformanceProvider = ProductPerformanceFamily();

/// See also [productPerformance].
class ProductPerformanceFamily
    extends Family<AsyncValue<List<ProductPerformanceEntity>>> {
  /// See also [productPerformance].
  const ProductPerformanceFamily();

  /// See also [productPerformance].
  ProductPerformanceProvider call(
    DateRange period, {
    required bool sortByQty,
  }) {
    return ProductPerformanceProvider(
      period,
      sortByQty: sortByQty,
    );
  }

  @override
  ProductPerformanceProvider getProviderOverride(
    covariant ProductPerformanceProvider provider,
  ) {
    return call(
      provider.period,
      sortByQty: provider.sortByQty,
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
  String? get name => r'productPerformanceProvider';
}

/// See also [productPerformance].
class ProductPerformanceProvider
    extends AutoDisposeFutureProvider<List<ProductPerformanceEntity>> {
  /// See also [productPerformance].
  ProductPerformanceProvider(
    DateRange period, {
    required bool sortByQty,
  }) : this._internal(
          (ref) => productPerformance(
            ref as ProductPerformanceRef,
            period,
            sortByQty: sortByQty,
          ),
          from: productPerformanceProvider,
          name: r'productPerformanceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productPerformanceHash,
          dependencies: ProductPerformanceFamily._dependencies,
          allTransitiveDependencies:
              ProductPerformanceFamily._allTransitiveDependencies,
          period: period,
          sortByQty: sortByQty,
        );

  ProductPerformanceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
    required this.sortByQty,
  }) : super.internal();

  final DateRange period;
  final bool sortByQty;

  @override
  Override overrideWith(
    FutureOr<List<ProductPerformanceEntity>> Function(
            ProductPerformanceRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductPerformanceProvider._internal(
        (ref) => create(ref as ProductPerformanceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
        sortByQty: sortByQty,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ProductPerformanceEntity>>
      createElement() {
    return _ProductPerformanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductPerformanceProvider &&
        other.period == period &&
        other.sortByQty == sortByQty;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);
    hash = _SystemHash.combine(hash, sortByQty.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProductPerformanceRef
    on AutoDisposeFutureProviderRef<List<ProductPerformanceEntity>> {
  /// The parameter `period` of this provider.
  DateRange get period;

  /// The parameter `sortByQty` of this provider.
  bool get sortByQty;
}

class _ProductPerformanceProviderElement
    extends AutoDisposeFutureProviderElement<List<ProductPerformanceEntity>>
    with ProductPerformanceRef {
  _ProductPerformanceProviderElement(super.provider);

  @override
  DateRange get period => (origin as ProductPerformanceProvider).period;
  @override
  bool get sortByQty => (origin as ProductPerformanceProvider).sortByQty;
}

String _$categoryReportHash() => r'8b0ef4c80be7e27a65fb6fb58ab5561811457c17';

/// See also [categoryReport].
@ProviderFor(categoryReport)
const categoryReportProvider = CategoryReportFamily();

/// See also [categoryReport].
class CategoryReportFamily
    extends Family<AsyncValue<List<CategoryReportEntity>>> {
  /// See also [categoryReport].
  const CategoryReportFamily();

  /// See also [categoryReport].
  CategoryReportProvider call(
    DateRange period,
  ) {
    return CategoryReportProvider(
      period,
    );
  }

  @override
  CategoryReportProvider getProviderOverride(
    covariant CategoryReportProvider provider,
  ) {
    return call(
      provider.period,
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
  String? get name => r'categoryReportProvider';
}

/// See also [categoryReport].
class CategoryReportProvider
    extends AutoDisposeFutureProvider<List<CategoryReportEntity>> {
  /// See also [categoryReport].
  CategoryReportProvider(
    DateRange period,
  ) : this._internal(
          (ref) => categoryReport(
            ref as CategoryReportRef,
            period,
          ),
          from: categoryReportProvider,
          name: r'categoryReportProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryReportHash,
          dependencies: CategoryReportFamily._dependencies,
          allTransitiveDependencies:
              CategoryReportFamily._allTransitiveDependencies,
          period: period,
        );

  CategoryReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final DateRange period;

  @override
  Override overrideWith(
    FutureOr<List<CategoryReportEntity>> Function(CategoryReportRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryReportProvider._internal(
        (ref) => create(ref as CategoryReportRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CategoryReportEntity>> createElement() {
    return _CategoryReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryReportProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoryReportRef
    on AutoDisposeFutureProviderRef<List<CategoryReportEntity>> {
  /// The parameter `period` of this provider.
  DateRange get period;
}

class _CategoryReportProviderElement
    extends AutoDisposeFutureProviderElement<List<CategoryReportEntity>>
    with CategoryReportRef {
  _CategoryReportProviderElement(super.provider);

  @override
  DateRange get period => (origin as CategoryReportProvider).period;
}

String _$profitReportHash() => r'c3438feb498408b0e74b8d079b6e9aa6832db0e4';

/// See also [profitReport].
@ProviderFor(profitReport)
const profitReportProvider = ProfitReportFamily();

/// See also [profitReport].
class ProfitReportFamily
    extends Family<AsyncValue<List<ProductPerformanceEntity>>> {
  /// See also [profitReport].
  const ProfitReportFamily();

  /// See also [profitReport].
  ProfitReportProvider call(
    DateRange period,
  ) {
    return ProfitReportProvider(
      period,
    );
  }

  @override
  ProfitReportProvider getProviderOverride(
    covariant ProfitReportProvider provider,
  ) {
    return call(
      provider.period,
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
  String? get name => r'profitReportProvider';
}

/// See also [profitReport].
class ProfitReportProvider
    extends AutoDisposeFutureProvider<List<ProductPerformanceEntity>> {
  /// See also [profitReport].
  ProfitReportProvider(
    DateRange period,
  ) : this._internal(
          (ref) => profitReport(
            ref as ProfitReportRef,
            period,
          ),
          from: profitReportProvider,
          name: r'profitReportProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profitReportHash,
          dependencies: ProfitReportFamily._dependencies,
          allTransitiveDependencies:
              ProfitReportFamily._allTransitiveDependencies,
          period: period,
        );

  ProfitReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final DateRange period;

  @override
  Override overrideWith(
    FutureOr<List<ProductPerformanceEntity>> Function(ProfitReportRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfitReportProvider._internal(
        (ref) => create(ref as ProfitReportRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ProductPerformanceEntity>>
      createElement() {
    return _ProfitReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfitReportProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProfitReportRef
    on AutoDisposeFutureProviderRef<List<ProductPerformanceEntity>> {
  /// The parameter `period` of this provider.
  DateRange get period;
}

class _ProfitReportProviderElement
    extends AutoDisposeFutureProviderElement<List<ProductPerformanceEntity>>
    with ProfitReportRef {
  _ProfitReportProviderElement(super.provider);

  @override
  DateRange get period => (origin as ProfitReportProvider).period;
}

String _$storeNameHash() => r'b5f772103a1d8a88133ae265fb6cc0e1e6614043';

/// See also [storeName].
@ProviderFor(storeName)
final storeNameProvider = AutoDisposeFutureProvider<String>.internal(
  storeName,
  name: r'storeNameProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$storeNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StoreNameRef = AutoDisposeFutureProviderRef<String>;
String _$exportReportNotifierHash() =>
    r'f3455d7d9bc502a324f84541a5b087686f72a4ee';

/// See also [ExportReportNotifier].
@ProviderFor(ExportReportNotifier)
final exportReportNotifierProvider = AutoDisposeNotifierProvider<
    ExportReportNotifier, AsyncValue<void>>.internal(
  ExportReportNotifier.new,
  name: r'exportReportNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exportReportNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExportReportNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
