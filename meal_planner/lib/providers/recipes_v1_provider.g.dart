// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipes_v1_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipesV1RepositoryHash() =>
    r'fd293a9556723353301896ccf5709e0b94475e15';

/// See also [recipesV1Repository].
@ProviderFor(recipesV1Repository)
final recipesV1RepositoryProvider =
    AutoDisposeProvider<RecipesV1Repository>.internal(
      recipesV1Repository,
      name: r'recipesV1RepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recipesV1RepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecipesV1RepositoryRef = AutoDisposeProviderRef<RecipesV1Repository>;
String _$recipesV1CountHash() => r'a7eec191e8e2168c238fc5d9d774e5806f2e86b5';

/// See also [recipesV1Count].
@ProviderFor(recipesV1Count)
final recipesV1CountProvider = AutoDisposeFutureProvider<int>.internal(
  recipesV1Count,
  name: r'recipesV1CountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recipesV1CountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecipesV1CountRef = AutoDisposeFutureProviderRef<int>;
String _$recipeSearchV1NotifierHash() =>
    r'273971650a7cc5d5c4114b5dc73cc17959dd0571';

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

abstract class _$RecipeSearchV1Notifier
    extends BuildlessAutoDisposeStreamNotifier<List<Recipe>> {
  late final String query;

  Stream<List<Recipe>> build(String query);
}

/// See also [RecipeSearchV1Notifier].
@ProviderFor(RecipeSearchV1Notifier)
const recipeSearchV1NotifierProvider = RecipeSearchV1NotifierFamily();

/// See also [RecipeSearchV1Notifier].
class RecipeSearchV1NotifierFamily extends Family<AsyncValue<List<Recipe>>> {
  /// See also [RecipeSearchV1Notifier].
  const RecipeSearchV1NotifierFamily();

  /// See also [RecipeSearchV1Notifier].
  RecipeSearchV1NotifierProvider call(String query) {
    return RecipeSearchV1NotifierProvider(query);
  }

  @override
  RecipeSearchV1NotifierProvider getProviderOverride(
    covariant RecipeSearchV1NotifierProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recipeSearchV1NotifierProvider';
}

/// See also [RecipeSearchV1Notifier].
class RecipeSearchV1NotifierProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          RecipeSearchV1Notifier,
          List<Recipe>
        > {
  /// See also [RecipeSearchV1Notifier].
  RecipeSearchV1NotifierProvider(String query)
    : this._internal(
        () => RecipeSearchV1Notifier()..query = query,
        from: recipeSearchV1NotifierProvider,
        name: r'recipeSearchV1NotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recipeSearchV1NotifierHash,
        dependencies: RecipeSearchV1NotifierFamily._dependencies,
        allTransitiveDependencies:
            RecipeSearchV1NotifierFamily._allTransitiveDependencies,
        query: query,
      );

  RecipeSearchV1NotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Stream<List<Recipe>> runNotifierBuild(
    covariant RecipeSearchV1Notifier notifier,
  ) {
    return notifier.build(query);
  }

  @override
  Override overrideWith(RecipeSearchV1Notifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: RecipeSearchV1NotifierProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<RecipeSearchV1Notifier, List<Recipe>>
  createElement() {
    return _RecipeSearchV1NotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeSearchV1NotifierProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecipeSearchV1NotifierRef
    on AutoDisposeStreamNotifierProviderRef<List<Recipe>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _RecipeSearchV1NotifierProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          RecipeSearchV1Notifier,
          List<Recipe>
        >
    with RecipeSearchV1NotifierRef {
  _RecipeSearchV1NotifierProviderElement(super.provider);

  @override
  String get query => (origin as RecipeSearchV1NotifierProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
