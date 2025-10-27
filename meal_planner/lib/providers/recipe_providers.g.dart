// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipesHash() => r'9a4cfc301eaacced8d16e78cd5a27fe243422540';

/// See also [recipes].
@ProviderFor(recipes)
final recipesProvider = AutoDisposeStreamProvider<List<Recipe>>.internal(
  recipes,
  name: r'recipesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recipesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecipesRef = AutoDisposeStreamProviderRef<List<Recipe>>;
String _$recipeHash() => r'9edd69cbfe01361410081ed2f5c76eb8605f1465';

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

/// See also [recipe].
@ProviderFor(recipe)
const recipeProvider = RecipeFamily();

/// See also [recipe].
class RecipeFamily extends Family<AsyncValue<Recipe?>> {
  /// See also [recipe].
  const RecipeFamily();

  /// See also [recipe].
  RecipeProvider call(String recipeId) {
    return RecipeProvider(recipeId);
  }

  @override
  RecipeProvider getProviderOverride(covariant RecipeProvider provider) {
    return call(provider.recipeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recipeProvider';
}

/// See also [recipe].
class RecipeProvider extends AutoDisposeFutureProvider<Recipe?> {
  /// See also [recipe].
  RecipeProvider(String recipeId)
    : this._internal(
        (ref) => recipe(ref as RecipeRef, recipeId),
        from: recipeProvider,
        name: r'recipeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recipeHash,
        dependencies: RecipeFamily._dependencies,
        allTransitiveDependencies: RecipeFamily._allTransitiveDependencies,
        recipeId: recipeId,
      );

  RecipeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.recipeId,
  }) : super.internal();

  final String recipeId;

  @override
  Override overrideWith(FutureOr<Recipe?> Function(RecipeRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: RecipeProvider._internal(
        (ref) => create(ref as RecipeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        recipeId: recipeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Recipe?> createElement() {
    return _RecipeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeProvider && other.recipeId == recipeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, recipeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecipeRef on AutoDisposeFutureProviderRef<Recipe?> {
  /// The parameter `recipeId` of this provider.
  String get recipeId;
}

class _RecipeProviderElement extends AutoDisposeFutureProviderElement<Recipe?>
    with RecipeRef {
  _RecipeProviderElement(super.provider);

  @override
  String get recipeId => (origin as RecipeProvider).recipeId;
}

String _$recipeSaveNotifierHash() =>
    r'70926895bcf8217055aeba0641b4bc0e93ed3de3';

/// See also [RecipeSaveNotifier].
@ProviderFor(RecipeSaveNotifier)
final recipeSaveNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RecipeSaveNotifier, void>.internal(
      RecipeSaveNotifier.new,
      name: r'recipeSaveNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recipeSaveNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecipeSaveNotifier = AutoDisposeAsyncNotifier<void>;
String _$recipeSearchNotifierHash() =>
    r'e1a740d5a0d6e1cc88a01757f20d03888a77e0ce';

/// See also [RecipeSearchNotifier].
@ProviderFor(RecipeSearchNotifier)
final recipeSearchNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      RecipeSearchNotifier,
      List<SearchResult>
    >.internal(
      RecipeSearchNotifier.new,
      name: r'recipeSearchNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recipeSearchNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecipeSearchNotifier = AutoDisposeAsyncNotifier<List<SearchResult>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
