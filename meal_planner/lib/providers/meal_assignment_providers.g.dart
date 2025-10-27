// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_assignment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mealAssignmentsForDayHash() =>
    r'6617a718302200ff9c9351f152248f868ba83417';

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

/// See also [mealAssignmentsForDay].
@ProviderFor(mealAssignmentsForDay)
const mealAssignmentsForDayProvider = MealAssignmentsForDayFamily();

/// See also [mealAssignmentsForDay].
class MealAssignmentsForDayFamily
    extends Family<AsyncValue<List<MealAssignment>>> {
  /// See also [mealAssignmentsForDay].
  const MealAssignmentsForDayFamily();

  /// See also [mealAssignmentsForDay].
  MealAssignmentsForDayProvider call(String isoDate) {
    return MealAssignmentsForDayProvider(isoDate);
  }

  @override
  MealAssignmentsForDayProvider getProviderOverride(
    covariant MealAssignmentsForDayProvider provider,
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
  String? get name => r'mealAssignmentsForDayProvider';
}

/// See also [mealAssignmentsForDay].
class MealAssignmentsForDayProvider
    extends AutoDisposeStreamProvider<List<MealAssignment>> {
  /// See also [mealAssignmentsForDay].
  MealAssignmentsForDayProvider(String isoDate)
    : this._internal(
        (ref) =>
            mealAssignmentsForDay(ref as MealAssignmentsForDayRef, isoDate),
        from: mealAssignmentsForDayProvider,
        name: r'mealAssignmentsForDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mealAssignmentsForDayHash,
        dependencies: MealAssignmentsForDayFamily._dependencies,
        allTransitiveDependencies:
            MealAssignmentsForDayFamily._allTransitiveDependencies,
        isoDate: isoDate,
      );

  MealAssignmentsForDayProvider._internal(
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
    Stream<List<MealAssignment>> Function(MealAssignmentsForDayRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MealAssignmentsForDayProvider._internal(
        (ref) => create(ref as MealAssignmentsForDayRef),
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
  AutoDisposeStreamProviderElement<List<MealAssignment>> createElement() {
    return _MealAssignmentsForDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MealAssignmentsForDayProvider && other.isoDate == isoDate;
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
mixin MealAssignmentsForDayRef
    on AutoDisposeStreamProviderRef<List<MealAssignment>> {
  /// The parameter `isoDate` of this provider.
  String get isoDate;
}

class _MealAssignmentsForDayProviderElement
    extends AutoDisposeStreamProviderElement<List<MealAssignment>>
    with MealAssignmentsForDayRef {
  _MealAssignmentsForDayProviderElement(super.provider);

  @override
  String get isoDate => (origin as MealAssignmentsForDayProvider).isoDate;
}

String _$weekMealAssignmentsHash() =>
    r'053acffc89bb7a592abb0794c473f3efe865eb56';

/// See also [weekMealAssignments].
@ProviderFor(weekMealAssignments)
const weekMealAssignmentsProvider = WeekMealAssignmentsFamily();

/// See also [weekMealAssignments].
class WeekMealAssignmentsFamily
    extends Family<AsyncValue<Map<String, List<MealAssignment>>>> {
  /// See also [weekMealAssignments].
  const WeekMealAssignmentsFamily();

  /// See also [weekMealAssignments].
  WeekMealAssignmentsProvider call(String startIsoDate) {
    return WeekMealAssignmentsProvider(startIsoDate);
  }

  @override
  WeekMealAssignmentsProvider getProviderOverride(
    covariant WeekMealAssignmentsProvider provider,
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
  String? get name => r'weekMealAssignmentsProvider';
}

/// See also [weekMealAssignments].
class WeekMealAssignmentsProvider
    extends AutoDisposeStreamProvider<Map<String, List<MealAssignment>>> {
  /// See also [weekMealAssignments].
  WeekMealAssignmentsProvider(String startIsoDate)
    : this._internal(
        (ref) =>
            weekMealAssignments(ref as WeekMealAssignmentsRef, startIsoDate),
        from: weekMealAssignmentsProvider,
        name: r'weekMealAssignmentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weekMealAssignmentsHash,
        dependencies: WeekMealAssignmentsFamily._dependencies,
        allTransitiveDependencies:
            WeekMealAssignmentsFamily._allTransitiveDependencies,
        startIsoDate: startIsoDate,
      );

  WeekMealAssignmentsProvider._internal(
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
    Stream<Map<String, List<MealAssignment>>> Function(
      WeekMealAssignmentsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeekMealAssignmentsProvider._internal(
        (ref) => create(ref as WeekMealAssignmentsRef),
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
  AutoDisposeStreamProviderElement<Map<String, List<MealAssignment>>>
  createElement() {
    return _WeekMealAssignmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekMealAssignmentsProvider &&
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
mixin WeekMealAssignmentsRef
    on AutoDisposeStreamProviderRef<Map<String, List<MealAssignment>>> {
  /// The parameter `startIsoDate` of this provider.
  String get startIsoDate;
}

class _WeekMealAssignmentsProviderElement
    extends AutoDisposeStreamProviderElement<Map<String, List<MealAssignment>>>
    with WeekMealAssignmentsRef {
  _WeekMealAssignmentsProviderElement(super.provider);

  @override
  String get startIsoDate =>
      (origin as WeekMealAssignmentsProvider).startIsoDate;
}

String _$mealAssignmentNotifierHash() =>
    r'5584496d36c46c52253de8d39c091ffbc3ecf4a3';

/// See also [MealAssignmentNotifier].
@ProviderFor(MealAssignmentNotifier)
final mealAssignmentNotifierProvider =
    AutoDisposeAsyncNotifierProvider<MealAssignmentNotifier, void>.internal(
      MealAssignmentNotifier.new,
      name: r'mealAssignmentNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mealAssignmentNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MealAssignmentNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
