// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipesForDayHash() => r'36f05de27207c7da18df212f85d32ec8e1e1ee81';

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

/// See also [recipesForDay].
@ProviderFor(recipesForDay)
const recipesForDayProvider = RecipesForDayFamily();

/// See also [recipesForDay].
class RecipesForDayFamily extends Family<AsyncValue<List<Recipe>>> {
  /// See also [recipesForDay].
  const RecipesForDayFamily();

  /// See also [recipesForDay].
  RecipesForDayProvider call(String isoDate) {
    return RecipesForDayProvider(isoDate);
  }

  @override
  RecipesForDayProvider getProviderOverride(
    covariant RecipesForDayProvider provider,
  ) {
    return call(provider.isoDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recipesForDayProvider';
}

/// See also [recipesForDay].
class RecipesForDayProvider extends AutoDisposeFutureProvider<List<Recipe>> {
  /// See also [recipesForDay].
  RecipesForDayProvider(String isoDate)
    : this._internal(
        (ref) => recipesForDay(ref as RecipesForDayRef, isoDate),
        from: recipesForDayProvider,
        name: r'recipesForDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recipesForDayHash,
        dependencies: RecipesForDayFamily._dependencies,
        allTransitiveDependencies:
            RecipesForDayFamily._allTransitiveDependencies,
        isoDate: isoDate,
      );

  RecipesForDayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isoDate,
  }) : super.internal();

  final String isoDate;

  @override
  Override overrideWith(
    FutureOr<List<Recipe>> Function(RecipesForDayRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecipesForDayProvider._internal(
        (ref) => create(ref as RecipesForDayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isoDate: isoDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Recipe>> createElement() {
    return _RecipesForDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipesForDayProvider && other.isoDate == isoDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isoDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecipesForDayRef on AutoDisposeFutureProviderRef<List<Recipe>> {
  /// The parameter `isoDate` of this provider.
  String get isoDate;
}

class _RecipesForDayProviderElement
    extends AutoDisposeFutureProviderElement<List<Recipe>>
    with RecipesForDayRef {
  _RecipesForDayProviderElement(super.provider);

  @override
  String get isoDate => (origin as RecipesForDayProvider).isoDate;
}

String _$weekMealCountsHash() => r'33bd2d91d00e333f0e55295acf2862fe1cb9fa53';

/// See also [weekMealCounts].
@ProviderFor(weekMealCounts)
const weekMealCountsProvider = WeekMealCountsFamily();

/// See also [weekMealCounts].
class WeekMealCountsFamily extends Family<AsyncValue<Map<String, int>>> {
  /// See also [weekMealCounts].
  const WeekMealCountsFamily();

  /// See also [weekMealCounts].
  WeekMealCountsProvider call(String startIsoDate) {
    return WeekMealCountsProvider(startIsoDate);
  }

  @override
  WeekMealCountsProvider getProviderOverride(
    covariant WeekMealCountsProvider provider,
  ) {
    return call(provider.startIsoDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weekMealCountsProvider';
}

/// See also [weekMealCounts].
class WeekMealCountsProvider
    extends AutoDisposeFutureProvider<Map<String, int>> {
  /// See also [weekMealCounts].
  WeekMealCountsProvider(String startIsoDate)
    : this._internal(
        (ref) => weekMealCounts(ref as WeekMealCountsRef, startIsoDate),
        from: weekMealCountsProvider,
        name: r'weekMealCountsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weekMealCountsHash,
        dependencies: WeekMealCountsFamily._dependencies,
        allTransitiveDependencies:
            WeekMealCountsFamily._allTransitiveDependencies,
        startIsoDate: startIsoDate,
      );

  WeekMealCountsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startIsoDate,
  }) : super.internal();

  final String startIsoDate;

  @override
  Override overrideWith(
    FutureOr<Map<String, int>> Function(WeekMealCountsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeekMealCountsProvider._internal(
        (ref) => create(ref as WeekMealCountsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startIsoDate: startIsoDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, int>> createElement() {
    return _WeekMealCountsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekMealCountsProvider &&
        other.startIsoDate == startIsoDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startIsoDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeekMealCountsRef on AutoDisposeFutureProviderRef<Map<String, int>> {
  /// The parameter `startIsoDate` of this provider.
  String get startIsoDate;
}

class _WeekMealCountsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, int>>
    with WeekMealCountsRef {
  _WeekMealCountsProviderElement(super.provider);

  @override
  String get startIsoDate => (origin as WeekMealCountsProvider).startIsoDate;
}

String _$weekTotalTimeHash() => r'd6cfdab49d8310928c14eacc09565691f6454f10';

/// See also [weekTotalTime].
@ProviderFor(weekTotalTime)
const weekTotalTimeProvider = WeekTotalTimeFamily();

/// See also [weekTotalTime].
class WeekTotalTimeFamily extends Family<AsyncValue<double>> {
  /// See also [weekTotalTime].
  const WeekTotalTimeFamily();

  /// See also [weekTotalTime].
  WeekTotalTimeProvider call(String startIsoDate) {
    return WeekTotalTimeProvider(startIsoDate);
  }

  @override
  WeekTotalTimeProvider getProviderOverride(
    covariant WeekTotalTimeProvider provider,
  ) {
    return call(provider.startIsoDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weekTotalTimeProvider';
}

/// See also [weekTotalTime].
class WeekTotalTimeProvider extends AutoDisposeFutureProvider<double> {
  /// See also [weekTotalTime].
  WeekTotalTimeProvider(String startIsoDate)
    : this._internal(
        (ref) => weekTotalTime(ref as WeekTotalTimeRef, startIsoDate),
        from: weekTotalTimeProvider,
        name: r'weekTotalTimeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weekTotalTimeHash,
        dependencies: WeekTotalTimeFamily._dependencies,
        allTransitiveDependencies:
            WeekTotalTimeFamily._allTransitiveDependencies,
        startIsoDate: startIsoDate,
      );

  WeekTotalTimeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startIsoDate,
  }) : super.internal();

  final String startIsoDate;

  @override
  Override overrideWith(
    FutureOr<double> Function(WeekTotalTimeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeekTotalTimeProvider._internal(
        (ref) => create(ref as WeekTotalTimeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startIsoDate: startIsoDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<double> createElement() {
    return _WeekTotalTimeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekTotalTimeProvider && other.startIsoDate == startIsoDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startIsoDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeekTotalTimeRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `startIsoDate` of this provider.
  String get startIsoDate;
}

class _WeekTotalTimeProviderElement
    extends AutoDisposeFutureProviderElement<double>
    with WeekTotalTimeRef {
  _WeekTotalTimeProviderElement(super.provider);

  @override
  String get startIsoDate => (origin as WeekTotalTimeProvider).startIsoDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
