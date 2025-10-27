// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$generateShoppingListHash() =>
    r'040075dbe63cfe059acb7bbf9591bc8f465f665e';

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

/// See also [generateShoppingList].
@ProviderFor(generateShoppingList)
const generateShoppingListProvider = GenerateShoppingListFamily();

/// See also [generateShoppingList].
class GenerateShoppingListFamily extends Family<AsyncValue<ShoppingList>> {
  /// See also [generateShoppingList].
  const GenerateShoppingListFamily();

  /// See also [generateShoppingList].
  GenerateShoppingListProvider call(List<String> assignmentIds) {
    return GenerateShoppingListProvider(assignmentIds);
  }

  @override
  GenerateShoppingListProvider getProviderOverride(
    covariant GenerateShoppingListProvider provider,
  ) {
    return call(provider.assignmentIds);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'generateShoppingListProvider';
}

/// See also [generateShoppingList].
class GenerateShoppingListProvider
    extends AutoDisposeFutureProvider<ShoppingList> {
  /// See also [generateShoppingList].
  GenerateShoppingListProvider(List<String> assignmentIds)
    : this._internal(
        (ref) =>
            generateShoppingList(ref as GenerateShoppingListRef, assignmentIds),
        from: generateShoppingListProvider,
        name: r'generateShoppingListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$generateShoppingListHash,
        dependencies: GenerateShoppingListFamily._dependencies,
        allTransitiveDependencies:
            GenerateShoppingListFamily._allTransitiveDependencies,
        assignmentIds: assignmentIds,
      );

  GenerateShoppingListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.assignmentIds,
  }) : super.internal();

  final List<String> assignmentIds;

  @override
  Override overrideWith(
    FutureOr<ShoppingList> Function(GenerateShoppingListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GenerateShoppingListProvider._internal(
        (ref) => create(ref as GenerateShoppingListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        assignmentIds: assignmentIds,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ShoppingList> createElement() {
    return _GenerateShoppingListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GenerateShoppingListProvider &&
        other.assignmentIds == assignmentIds;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, assignmentIds.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GenerateShoppingListRef on AutoDisposeFutureProviderRef<ShoppingList> {
  /// The parameter `assignmentIds` of this provider.
  List<String> get assignmentIds;
}

class _GenerateShoppingListProviderElement
    extends AutoDisposeFutureProviderElement<ShoppingList>
    with GenerateShoppingListRef {
  _GenerateShoppingListProviderElement(super.provider);

  @override
  List<String> get assignmentIds =>
      (origin as GenerateShoppingListProvider).assignmentIds;
}

String _$shoppingListNotifierHash() =>
    r'a29ddd3c52fe32c275c9b4385257d1be9c89cf97';

/// See also [ShoppingListNotifier].
@ProviderFor(ShoppingListNotifier)
final shoppingListNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ShoppingListNotifier, void>.internal(
      ShoppingListNotifier.new,
      name: r'shoppingListNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shoppingListNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShoppingListNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
