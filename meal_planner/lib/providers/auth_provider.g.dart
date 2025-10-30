// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentUserIdHash() => r'ad711866a44c86d2bd1af52f6dc972ff1b5f63d6';

/// See also [currentUserId].
@ProviderFor(currentUserId)
final currentUserIdProvider = AutoDisposeProvider<String?>.internal(
  currentUserId,
  name: r'currentUserIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserIdRef = AutoDisposeProviderRef<String?>;
String _$authInitializerNotifierHash() =>
    r'3b228360176a1713f99b6299c39b9edf91cc7b7f';

/// See also [AuthInitializerNotifier].
@ProviderFor(AuthInitializerNotifier)
final authInitializerNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthInitializerNotifier, void>.internal(
      AuthInitializerNotifier.new,
      name: r'authInitializerNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authInitializerNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthInitializerNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
