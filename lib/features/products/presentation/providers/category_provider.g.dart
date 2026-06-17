// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryLocalDatasourceHash() =>
    r'5eedaa1e7d4627a4e527225b81780f079c7f26bb';

/// See also [categoryLocalDatasource].
@ProviderFor(categoryLocalDatasource)
final categoryLocalDatasourceProvider =
    AutoDisposeProvider<CategoryLocalDatasource>.internal(
  categoryLocalDatasource,
  name: r'categoryLocalDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryLocalDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoryLocalDatasourceRef
    = AutoDisposeProviderRef<CategoryLocalDatasource>;
String _$categoryRepositoryHash() =>
    r'8d4291f2919e4f94ea9816c3fbf6cd1f63d43a0f';

/// See also [categoryRepository].
@ProviderFor(categoryRepository)
final categoryRepositoryProvider =
    AutoDisposeProvider<CategoryRepository>.internal(
  categoryRepository,
  name: r'categoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoryRepositoryRef = AutoDisposeProviderRef<CategoryRepository>;
String _$getAllCategoriesUsecaseHash() =>
    r'889a3a788077094b1499b0cbde1bc0d7bb8e3cf5';

/// See also [getAllCategoriesUsecase].
@ProviderFor(getAllCategoriesUsecase)
final getAllCategoriesUsecaseProvider =
    AutoDisposeProvider<GetAllCategoriesUsecase>.internal(
  getAllCategoriesUsecase,
  name: r'getAllCategoriesUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getAllCategoriesUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetAllCategoriesUsecaseRef
    = AutoDisposeProviderRef<GetAllCategoriesUsecase>;
String _$createCategoryUsecaseHash() =>
    r'600db1e049f6103d86b292fbd690dafd9e9899f6';

/// See also [createCategoryUsecase].
@ProviderFor(createCategoryUsecase)
final createCategoryUsecaseProvider =
    AutoDisposeProvider<CreateCategoryUsecase>.internal(
  createCategoryUsecase,
  name: r'createCategoryUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createCategoryUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CreateCategoryUsecaseRef
    = AutoDisposeProviderRef<CreateCategoryUsecase>;
String _$updateCategoryUsecaseHash() =>
    r'00a62255c1bc88457d3fabcca1fdfc8997470707';

/// See also [updateCategoryUsecase].
@ProviderFor(updateCategoryUsecase)
final updateCategoryUsecaseProvider =
    AutoDisposeProvider<UpdateCategoryUsecase>.internal(
  updateCategoryUsecase,
  name: r'updateCategoryUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateCategoryUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UpdateCategoryUsecaseRef
    = AutoDisposeProviderRef<UpdateCategoryUsecase>;
String _$deleteCategoryUsecaseHash() =>
    r'b710e7c915d5e4f8f568ac497b940978da8a4e67';

/// See also [deleteCategoryUsecase].
@ProviderFor(deleteCategoryUsecase)
final deleteCategoryUsecaseProvider =
    AutoDisposeProvider<DeleteCategoryUsecase>.internal(
  deleteCategoryUsecase,
  name: r'deleteCategoryUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteCategoryUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeleteCategoryUsecaseRef
    = AutoDisposeProviderRef<DeleteCategoryUsecase>;
String _$categoryListHash() => r'b111342e10a0727ec982ef302c69c47f22b64fe1';

/// Daftar semua kategori (is_deleted = 0).
///
/// Copied from [categoryList].
@ProviderFor(categoryList)
final categoryListProvider =
    AutoDisposeFutureProvider<List<CategoryEntity>>.internal(
  categoryList,
  name: r'categoryListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoryListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoryListRef = AutoDisposeFutureProviderRef<List<CategoryEntity>>;
String _$categoryNotifierHash() => r'cccf50511e902e960c7b7d594f1b63bad0cd0c5e';

/// State untuk operasi CRUD kategori.
///
/// Copied from [CategoryNotifier].
@ProviderFor(CategoryNotifier)
final categoryNotifierProvider =
    AutoDisposeNotifierProvider<CategoryNotifier, AsyncValue<void>>.internal(
  CategoryNotifier.new,
  name: r'categoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CategoryNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
