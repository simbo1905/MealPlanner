// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userPreferencesRepositoryHash() =>
    r'304671ab1955768e0e2b013239798c92ec328ee6';

/// Provider for the repository (can be overridden in tests)
///
/// Copied from [userPreferencesRepository].
@ProviderFor(userPreferencesRepository)
final userPreferencesRepositoryProvider =
    AutoDisposeProvider<UserPreferencesRepository>.internal(
      userPreferencesRepository,
      name: r'userPreferencesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userPreferencesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserPreferencesRepositoryRef =
    AutoDisposeProviderRef<UserPreferencesRepository>;
String _$userPreferencesHash() => r'5cd6026625503172b87b079aa9d12be416aa550f';

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

/// Load user preferences from repository
///
/// Copied from [userPreferences].
@ProviderFor(userPreferences)
const userPreferencesProvider = UserPreferencesFamily();

/// Load user preferences from repository
///
/// Copied from [userPreferences].
class UserPreferencesFamily extends Family<AsyncValue<UserPreferences>> {
  /// Load user preferences from repository
  ///
  /// Copied from [userPreferences].
  const UserPreferencesFamily();

  /// Load user preferences from repository
  ///
  /// Copied from [userPreferences].
  UserPreferencesProvider call(String userId) {
    return UserPreferencesProvider(userId);
  }

  @override
  UserPreferencesProvider getProviderOverride(
    covariant UserPreferencesProvider provider,
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
  String? get name => r'userPreferencesProvider';
}

/// Load user preferences from repository
///
/// Copied from [userPreferences].
class UserPreferencesProvider
    extends AutoDisposeFutureProvider<UserPreferences> {
  /// Load user preferences from repository
  ///
  /// Copied from [userPreferences].
  UserPreferencesProvider(String userId)
    : this._internal(
        (ref) => userPreferences(ref as UserPreferencesRef, userId),
        from: userPreferencesProvider,
        name: r'userPreferencesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userPreferencesHash,
        dependencies: UserPreferencesFamily._dependencies,
        allTransitiveDependencies:
            UserPreferencesFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserPreferencesProvider._internal(
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
    FutureOr<UserPreferences> Function(UserPreferencesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserPreferencesProvider._internal(
        (ref) => create(ref as UserPreferencesRef),
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
  AutoDisposeFutureProviderElement<UserPreferences> createElement() {
    return _UserPreferencesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPreferencesProvider && other.userId == userId;
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
mixin UserPreferencesRef on AutoDisposeFutureProviderRef<UserPreferences> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserPreferencesProviderElement
    extends AutoDisposeFutureProviderElement<UserPreferences>
    with UserPreferencesRef {
  _UserPreferencesProviderElement(super.provider);

  @override
  String get userId => (origin as UserPreferencesProvider).userId;
}

String _$userPreferencesNotifierHash() =>
    r'ef7cb4bf40970331888ce638c9fc4fe571b851c6';

abstract class _$UserPreferencesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<void> {
  late final String userId;

  FutureOr<void> build(String userId);
}

/// Notifier for updating preferences
///
/// Copied from [UserPreferencesNotifier].
@ProviderFor(UserPreferencesNotifier)
const userPreferencesNotifierProvider = UserPreferencesNotifierFamily();

/// Notifier for updating preferences
///
/// Copied from [UserPreferencesNotifier].
class UserPreferencesNotifierFamily extends Family<AsyncValue<void>> {
  /// Notifier for updating preferences
  ///
  /// Copied from [UserPreferencesNotifier].
  const UserPreferencesNotifierFamily();

  /// Notifier for updating preferences
  ///
  /// Copied from [UserPreferencesNotifier].
  UserPreferencesNotifierProvider call(String userId) {
    return UserPreferencesNotifierProvider(userId);
  }

  @override
  UserPreferencesNotifierProvider getProviderOverride(
    covariant UserPreferencesNotifierProvider provider,
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
  String? get name => r'userPreferencesNotifierProvider';
}

/// Notifier for updating preferences
///
/// Copied from [UserPreferencesNotifier].
class UserPreferencesNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<UserPreferencesNotifier, void> {
  /// Notifier for updating preferences
  ///
  /// Copied from [UserPreferencesNotifier].
  UserPreferencesNotifierProvider(String userId)
    : this._internal(
        () => UserPreferencesNotifier()..userId = userId,
        from: userPreferencesNotifierProvider,
        name: r'userPreferencesNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userPreferencesNotifierHash,
        dependencies: UserPreferencesNotifierFamily._dependencies,
        allTransitiveDependencies:
            UserPreferencesNotifierFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserPreferencesNotifierProvider._internal(
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
  FutureOr<void> runNotifierBuild(covariant UserPreferencesNotifier notifier) {
    return notifier.build(userId);
  }

  @override
  Override overrideWith(UserPreferencesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserPreferencesNotifierProvider._internal(
        () => create()..userId = userId,
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
  AutoDisposeAsyncNotifierProviderElement<UserPreferencesNotifier, void>
  createElement() {
    return _UserPreferencesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPreferencesNotifierProvider && other.userId == userId;
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
mixin UserPreferencesNotifierRef on AutoDisposeAsyncNotifierProviderRef<void> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserPreferencesNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<UserPreferencesNotifier, void>
    with UserPreferencesNotifierRef {
  _UserPreferencesNotifierProviderElement(super.provider);

  @override
  String get userId => (origin as UserPreferencesNotifierProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
