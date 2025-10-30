// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoritesRepositoryHash() =>
    r'1cddad067922eafe25b0850b0bb6a4c4f8e0a237';

/// See also [favoritesRepository].
@ProviderFor(favoritesRepository)
final favoritesRepositoryProvider =
    AutoDisposeProvider<FavoritesRepository>.internal(
      favoritesRepository,
      name: r'favoritesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoritesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoritesRepositoryRef = AutoDisposeProviderRef<FavoritesRepository>;
String _$favoriteRecipesHash() => r'a60afc85092ba28427340fed10fa94aa487032c0';

/// See also [favoriteRecipes].
@ProviderFor(favoriteRecipes)
final favoriteRecipesProvider =
    AutoDisposeStreamProvider<List<String>>.internal(
      favoriteRecipes,
      name: r'favoriteRecipesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoriteRecipesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoriteRecipesRef = AutoDisposeStreamProviderRef<List<String>>;
String _$favoriteSuggestionsHash() =>
    r'360a152e358f5f007bd0cd80e265b34dde1021cf';

/// See also [FavoriteSuggestions].
@ProviderFor(FavoriteSuggestions)
final favoriteSuggestionsProvider =
    AutoDisposeAsyncNotifierProvider<
      FavoriteSuggestions,
      List<String>
    >.internal(
      FavoriteSuggestions.new,
      name: r'favoriteSuggestionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoriteSuggestionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FavoriteSuggestions = AutoDisposeAsyncNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
