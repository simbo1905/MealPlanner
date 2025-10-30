// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mealRepositoryHash() => r'6f4ca00f9b6332244a2a6605c2128d8d4808005a';

/// Repository providers (overridable in tests)
///
/// Copied from [mealRepository].
@ProviderFor(mealRepository)
final mealRepositoryProvider = AutoDisposeProvider<MealRepository>.internal(
  mealRepository,
  name: r'mealRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mealRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MealRepositoryRef = AutoDisposeProviderRef<MealRepository>;
String _$userMealsHash() => r'04268005e00dabfb4f1b695ee8d202c84b5fc9c8';

/// Stream of meals for the signed-in user
/// Stream of meals for current user
///
/// Copied from [userMeals].
@ProviderFor(userMeals)
final userMealsProvider = AutoDisposeStreamProvider<List<Meal>>.internal(
  userMeals,
  name: r'userMealsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userMealsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserMealsRef = AutoDisposeStreamProviderRef<List<Meal>>;
String _$mealsForDateHash() => r'df30181952e5b8611b77d15ff732dd7a7767eb43';

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

/// Meals for a specific date
///
/// Copied from [mealsForDate].
@ProviderFor(mealsForDate)
const mealsForDateProvider = MealsForDateFamily();

/// Meals for a specific date
///
/// Copied from [mealsForDate].
class MealsForDateFamily extends Family<AsyncValue<List<Meal>>> {
  /// Meals for a specific date
  ///
  /// Copied from [mealsForDate].
  const MealsForDateFamily();

  /// Meals for a specific date
  ///
  /// Copied from [mealsForDate].
  MealsForDateProvider call(DateTime date) {
    return MealsForDateProvider(date);
  }

  @override
  MealsForDateProvider getProviderOverride(
    covariant MealsForDateProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mealsForDateProvider';
}

/// Meals for a specific date
///
/// Copied from [mealsForDate].
class MealsForDateProvider extends AutoDisposeProvider<AsyncValue<List<Meal>>> {
  /// Meals for a specific date
  ///
  /// Copied from [mealsForDate].
  MealsForDateProvider(DateTime date)
    : this._internal(
        (ref) => mealsForDate(ref as MealsForDateRef, date),
        from: mealsForDateProvider,
        name: r'mealsForDateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mealsForDateHash,
        dependencies: MealsForDateFamily._dependencies,
        allTransitiveDependencies:
            MealsForDateFamily._allTransitiveDependencies,
        date: date,
      );

  MealsForDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    AsyncValue<List<Meal>> Function(MealsForDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MealsForDateProvider._internal(
        (ref) => create(ref as MealsForDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<AsyncValue<List<Meal>>> createElement() {
    return _MealsForDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MealsForDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MealsForDateRef on AutoDisposeProviderRef<AsyncValue<List<Meal>>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _MealsForDateProviderElement
    extends AutoDisposeProviderElement<AsyncValue<List<Meal>>>
    with MealsForDateRef {
  _MealsForDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as MealsForDateProvider).date;
}

String _$mealsForDateRangeHash() => r'cf69eadbe0e7b0305b8339520748f557a7349734';

/// Meals for a date range (inclusive)
///
/// Copied from [mealsForDateRange].
@ProviderFor(mealsForDateRange)
const mealsForDateRangeProvider = MealsForDateRangeFamily();

/// Meals for a date range (inclusive)
///
/// Copied from [mealsForDateRange].
class MealsForDateRangeFamily extends Family<AsyncValue<List<Meal>>> {
  /// Meals for a date range (inclusive)
  ///
  /// Copied from [mealsForDateRange].
  const MealsForDateRangeFamily();

  /// Meals for a date range (inclusive)
  ///
  /// Copied from [mealsForDateRange].
  MealsForDateRangeProvider call(DateTime start, DateTime end) {
    return MealsForDateRangeProvider(start, end);
  }

  @override
  MealsForDateRangeProvider getProviderOverride(
    covariant MealsForDateRangeProvider provider,
  ) {
    return call(provider.start, provider.end);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mealsForDateRangeProvider';
}

/// Meals for a date range (inclusive)
///
/// Copied from [mealsForDateRange].
class MealsForDateRangeProvider
    extends AutoDisposeProvider<AsyncValue<List<Meal>>> {
  /// Meals for a date range (inclusive)
  ///
  /// Copied from [mealsForDateRange].
  MealsForDateRangeProvider(DateTime start, DateTime end)
    : this._internal(
        (ref) => mealsForDateRange(ref as MealsForDateRangeRef, start, end),
        from: mealsForDateRangeProvider,
        name: r'mealsForDateRangeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mealsForDateRangeHash,
        dependencies: MealsForDateRangeFamily._dependencies,
        allTransitiveDependencies:
            MealsForDateRangeFamily._allTransitiveDependencies,
        start: start,
        end: end,
      );

  MealsForDateRangeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
  }) : super.internal();

  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    AsyncValue<List<Meal>> Function(MealsForDateRangeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MealsForDateRangeProvider._internal(
        (ref) => create(ref as MealsForDateRangeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<AsyncValue<List<Meal>>> createElement() {
    return _MealsForDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MealsForDateRangeProvider &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MealsForDateRangeRef on AutoDisposeProviderRef<AsyncValue<List<Meal>>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _MealsForDateRangeProviderElement
    extends AutoDisposeProviderElement<AsyncValue<List<Meal>>>
    with MealsForDateRangeRef {
  _MealsForDateRangeProviderElement(super.provider);

  @override
  DateTime get start => (origin as MealsForDateRangeProvider).start;
  @override
  DateTime get end => (origin as MealsForDateRangeProvider).end;
}

String _$plannedMealCountHash() => r'3c5c9bfeee405e05b5e08a33a80e6923af437c33';

/// Planned meals count for next 30 days
///
/// Copied from [plannedMealCount].
@ProviderFor(plannedMealCount)
final plannedMealCountProvider = AutoDisposeProvider<AsyncValue<int>>.internal(
  plannedMealCount,
  name: r'plannedMealCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$plannedMealCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlannedMealCountRef = AutoDisposeProviderRef<AsyncValue<int>>;
String _$weekSectionsHash() => r'6fca112fb41f2c7ed7529c592724a1c356189cf5';

/// Week sections for infinite scroll
///
/// Copied from [weekSections].
@ProviderFor(weekSections)
const weekSectionsProvider = WeekSectionsFamily();

/// Week sections for infinite scroll
///
/// Copied from [weekSections].
class WeekSectionsFamily extends Family<AsyncValue<List<WeekSection>>> {
  /// Week sections for infinite scroll
  ///
  /// Copied from [weekSections].
  const WeekSectionsFamily();

  /// Week sections for infinite scroll
  ///
  /// Copied from [weekSections].
  WeekSectionsProvider call({required int weeksAround}) {
    return WeekSectionsProvider(weeksAround: weeksAround);
  }

  @override
  WeekSectionsProvider getProviderOverride(
    covariant WeekSectionsProvider provider,
  ) {
    return call(weeksAround: provider.weeksAround);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weekSectionsProvider';
}

/// Week sections for infinite scroll
///
/// Copied from [weekSections].
class WeekSectionsProvider
    extends AutoDisposeProvider<AsyncValue<List<WeekSection>>> {
  /// Week sections for infinite scroll
  ///
  /// Copied from [weekSections].
  WeekSectionsProvider({required int weeksAround})
    : this._internal(
        (ref) => weekSections(ref as WeekSectionsRef, weeksAround: weeksAround),
        from: weekSectionsProvider,
        name: r'weekSectionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weekSectionsHash,
        dependencies: WeekSectionsFamily._dependencies,
        allTransitiveDependencies:
            WeekSectionsFamily._allTransitiveDependencies,
        weeksAround: weeksAround,
      );

  WeekSectionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.weeksAround,
  }) : super.internal();

  final int weeksAround;

  @override
  Override overrideWith(
    AsyncValue<List<WeekSection>> Function(WeekSectionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeekSectionsProvider._internal(
        (ref) => create(ref as WeekSectionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        weeksAround: weeksAround,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<AsyncValue<List<WeekSection>>> createElement() {
    return _WeekSectionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekSectionsProvider && other.weeksAround == weeksAround;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, weeksAround.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeekSectionsRef on AutoDisposeProviderRef<AsyncValue<List<WeekSection>>> {
  /// The parameter `weeksAround` of this provider.
  int get weeksAround;
}

class _WeekSectionsProviderElement
    extends AutoDisposeProviderElement<AsyncValue<List<WeekSection>>>
    with WeekSectionsRef {
  _WeekSectionsProviderElement(super.provider);

  @override
  int get weeksAround => (origin as WeekSectionsProvider).weeksAround;
}

String _$selectedDateHash() => r'fb6368bb904939596c82fae9214a631685a128d8';

/// Selected date state
///
/// Copied from [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
      SelectedDate.new,
      name: r'selectedDateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
