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
String _$mealTemplateRepositoryHash() =>
    r'43d8079055c3534c328ab419bb97b5187ab69075';

/// See also [mealTemplateRepository].
@ProviderFor(mealTemplateRepository)
final mealTemplateRepositoryProvider =
    AutoDisposeProvider<MealTemplateRepository>.internal(
      mealTemplateRepository,
      name: r'mealTemplateRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mealTemplateRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MealTemplateRepositoryRef =
    AutoDisposeProviderRef<MealTemplateRepository>;
String _$mealsForDateHash() => r'095f5d95f2da10fa1e08a0866fbd7506d0656d25';

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

/// Get meals for a specific date
///
/// Copied from [mealsForDate].
@ProviderFor(mealsForDate)
const mealsForDateProvider = MealsForDateFamily();

/// Get meals for a specific date
///
/// Copied from [mealsForDate].
class MealsForDateFamily extends Family<List<Meal>> {
  /// Get meals for a specific date
  ///
  /// Copied from [mealsForDate].
  const MealsForDateFamily();

  /// Get meals for a specific date
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

/// Get meals for a specific date
///
/// Copied from [mealsForDate].
class MealsForDateProvider extends AutoDisposeProvider<List<Meal>> {
  /// Get meals for a specific date
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
  Override overrideWith(List<Meal> Function(MealsForDateRef provider) create) {
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
  AutoDisposeProviderElement<List<Meal>> createElement() {
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
mixin MealsForDateRef on AutoDisposeProviderRef<List<Meal>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _MealsForDateProviderElement
    extends AutoDisposeProviderElement<List<Meal>>
    with MealsForDateRef {
  _MealsForDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as MealsForDateProvider).date;
}

String _$mealsForDateRangeHash() => r'cfee31467289bdc26416e03418d7f4b9d48cfda4';

/// Get meals for a date range
///
/// Copied from [mealsForDateRange].
@ProviderFor(mealsForDateRange)
const mealsForDateRangeProvider = MealsForDateRangeFamily();

/// Get meals for a date range
///
/// Copied from [mealsForDateRange].
class MealsForDateRangeFamily extends Family<List<Meal>> {
  /// Get meals for a date range
  ///
  /// Copied from [mealsForDateRange].
  const MealsForDateRangeFamily();

  /// Get meals for a date range
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

/// Get meals for a date range
///
/// Copied from [mealsForDateRange].
class MealsForDateRangeProvider extends AutoDisposeProvider<List<Meal>> {
  /// Get meals for a date range
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
    List<Meal> Function(MealsForDateRangeRef provider) create,
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
  AutoDisposeProviderElement<List<Meal>> createElement() {
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
mixin MealsForDateRangeRef on AutoDisposeProviderRef<List<Meal>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _MealsForDateRangeProviderElement
    extends AutoDisposeProviderElement<List<Meal>>
    with MealsForDateRangeRef {
  _MealsForDateRangeProviderElement(super.provider);

  @override
  DateTime get start => (origin as MealsForDateRangeProvider).start;
  @override
  DateTime get end => (origin as MealsForDateRangeProvider).end;
}

String _$mealTemplatesHash() => r'5cf619b9a043c5f2d02d31796ea8ef3b50fe1eb7';

/// Get all meal templates
///
/// Copied from [mealTemplates].
@ProviderFor(mealTemplates)
final mealTemplatesProvider = AutoDisposeProvider<List<MealTemplate>>.internal(
  mealTemplates,
  name: r'mealTemplatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mealTemplatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MealTemplatesRef = AutoDisposeProviderRef<List<MealTemplate>>;
String _$mealTemplateByIdHash() => r'844db2346b35de83c32876bdf8568319b9c63a45';

/// Get template by ID
///
/// Copied from [mealTemplateById].
@ProviderFor(mealTemplateById)
const mealTemplateByIdProvider = MealTemplateByIdFamily();

/// Get template by ID
///
/// Copied from [mealTemplateById].
class MealTemplateByIdFamily extends Family<MealTemplate?> {
  /// Get template by ID
  ///
  /// Copied from [mealTemplateById].
  const MealTemplateByIdFamily();

  /// Get template by ID
  ///
  /// Copied from [mealTemplateById].
  MealTemplateByIdProvider call(String templateId) {
    return MealTemplateByIdProvider(templateId);
  }

  @override
  MealTemplateByIdProvider getProviderOverride(
    covariant MealTemplateByIdProvider provider,
  ) {
    return call(provider.templateId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mealTemplateByIdProvider';
}

/// Get template by ID
///
/// Copied from [mealTemplateById].
class MealTemplateByIdProvider extends AutoDisposeProvider<MealTemplate?> {
  /// Get template by ID
  ///
  /// Copied from [mealTemplateById].
  MealTemplateByIdProvider(String templateId)
    : this._internal(
        (ref) => mealTemplateById(ref as MealTemplateByIdRef, templateId),
        from: mealTemplateByIdProvider,
        name: r'mealTemplateByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mealTemplateByIdHash,
        dependencies: MealTemplateByIdFamily._dependencies,
        allTransitiveDependencies:
            MealTemplateByIdFamily._allTransitiveDependencies,
        templateId: templateId,
      );

  MealTemplateByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.templateId,
  }) : super.internal();

  final String templateId;

  @override
  Override overrideWith(
    MealTemplate? Function(MealTemplateByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MealTemplateByIdProvider._internal(
        (ref) => create(ref as MealTemplateByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        templateId: templateId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<MealTemplate?> createElement() {
    return _MealTemplateByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MealTemplateByIdProvider && other.templateId == templateId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, templateId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MealTemplateByIdRef on AutoDisposeProviderRef<MealTemplate?> {
  /// The parameter `templateId` of this provider.
  String get templateId;
}

class _MealTemplateByIdProviderElement
    extends AutoDisposeProviderElement<MealTemplate?>
    with MealTemplateByIdRef {
  _MealTemplateByIdProviderElement(super.provider);

  @override
  String get templateId => (origin as MealTemplateByIdProvider).templateId;
}

String _$plannedMealCountHash() => r'ec2dbb07849bb50c77ff233ef606f655f8f5d478';

/// Calculate planned meals count (meals from tomorrow onwards)
///
/// Copied from [plannedMealCount].
@ProviderFor(plannedMealCount)
final plannedMealCountProvider = AutoDisposeProvider<int>.internal(
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
typedef PlannedMealCountRef = AutoDisposeProviderRef<int>;
String _$weekSectionsHash() => r'0d7e0476cd6a52fc306a6d2c6f4f0611bc28287b';

/// Generate week sections for infinite scroll
///
/// Copied from [weekSections].
@ProviderFor(weekSections)
const weekSectionsProvider = WeekSectionsFamily();

/// Generate week sections for infinite scroll
///
/// Copied from [weekSections].
class WeekSectionsFamily extends Family<List<WeekSection>> {
  /// Generate week sections for infinite scroll
  ///
  /// Copied from [weekSections].
  const WeekSectionsFamily();

  /// Generate week sections for infinite scroll
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

/// Generate week sections for infinite scroll
///
/// Copied from [weekSections].
class WeekSectionsProvider extends AutoDisposeProvider<List<WeekSection>> {
  /// Generate week sections for infinite scroll
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
    List<WeekSection> Function(WeekSectionsRef provider) create,
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
  AutoDisposeProviderElement<List<WeekSection>> createElement() {
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
mixin WeekSectionsRef on AutoDisposeProviderRef<List<WeekSection>> {
  /// The parameter `weeksAround` of this provider.
  int get weeksAround;
}

class _WeekSectionsProviderElement
    extends AutoDisposeProviderElement<List<WeekSection>>
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
