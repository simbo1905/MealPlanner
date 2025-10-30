// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_favourites_v1_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userFavouritesV1RepositoryHash() =>
    r'4b00c89be5d6c4e71dbec9e12533ae4a0a6f5721';

/// See also [userFavouritesV1Repository].
@ProviderFor(userFavouritesV1Repository)
final userFavouritesV1RepositoryProvider =
    AutoDisposeProvider<UserFavouritesV1Repository>.internal(
      userFavouritesV1Repository,
      name: r'userFavouritesV1RepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userFavouritesV1RepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserFavouritesV1RepositoryRef =
    AutoDisposeProviderRef<UserFavouritesV1Repository>;
String _$userFavouriteIdsHash() => r'c01596e7aba9cf59cdba30e862a062708334c3c3';

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

/// See also [userFavouriteIds].
@ProviderFor(userFavouriteIds)
const userFavouriteIdsProvider = UserFavouriteIdsFamily();

/// See also [userFavouriteIds].
class UserFavouriteIdsFamily extends Family<AsyncValue<List<String>>> {
  /// See also [userFavouriteIds].
  const UserFavouriteIdsFamily();

  /// See also [userFavouriteIds].
  UserFavouriteIdsProvider call(String userId) {
    return UserFavouriteIdsProvider(userId);
  }

  @override
  UserFavouriteIdsProvider getProviderOverride(
    covariant UserFavouriteIdsProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userFavouriteIdsProvider';
}

/// See also [userFavouriteIds].
class UserFavouriteIdsProvider extends AutoDisposeStreamProvider<List<String>> {
  /// See also [userFavouriteIds].
  UserFavouriteIdsProvider(String userId)
    : this._internal(
        (ref) => userFavouriteIds(ref as UserFavouriteIdsRef, userId),
        from: userFavouriteIdsProvider,
        name: r'userFavouriteIdsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userFavouriteIdsHash,
        dependencies: UserFavouriteIdsFamily._dependencies,
        allTransitiveDependencies:
            UserFavouriteIdsFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserFavouriteIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<String>> Function(UserFavouriteIdsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserFavouriteIdsProvider._internal(
        (ref) => create(ref as UserFavouriteIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<String>> createElement() {
    return _UserFavouriteIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserFavouriteIdsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserFavouriteIdsRef on AutoDisposeStreamProviderRef<List<String>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserFavouriteIdsProviderElement
    extends AutoDisposeStreamProviderElement<List<String>>
    with UserFavouriteIdsRef {
  _UserFavouriteIdsProviderElement(super.provider);

  @override
  String get userId => (origin as UserFavouriteIdsProvider).userId;
}

String _$addUserFavouriteV1NotifierHash() =>
    r'67ae8616e3c60979a417d84b7ffaf8b70533a49e';

/// See also [AddUserFavouriteV1Notifier].
@ProviderFor(AddUserFavouriteV1Notifier)
final addUserFavouriteV1NotifierProvider =
    AutoDisposeAsyncNotifierProvider<AddUserFavouriteV1Notifier, void>.internal(
      AddUserFavouriteV1Notifier.new,
      name: r'addUserFavouriteV1NotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addUserFavouriteV1NotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AddUserFavouriteV1Notifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
