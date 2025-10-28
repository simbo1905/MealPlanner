import 'dart:async';
import 'package:meal_planner/models/meal.freezed_model.dart';
import 'package:flutter/foundation.dart';
import 'package:meal_planner/repositories/meal_repository.dart';

/// In-memory repository for meals used in demo/development.
class InMemoryMealRepository implements MealRepository {
  InMemoryMealRepository({DateTime Function()? clock})
      : _clock = clock ?? (() => DateTime.now());

  final DateTime Function() _clock;
  final Map<String, List<Meal>> _workingState = {};
  final Map<String, List<Meal>> _persistentState = {};
  final StreamController<Map<String, List<Meal>>> _stateController =
      StreamController<Map<String, List<Meal>>>.broadcast();

  /// Pre-seed exactly 10 deterministic meals across 14 days starting Monday of current week
  /// This ensures predictable test data matching spec requirements
  void seedDemoMeals() {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);

    // Get the start of the current week (Monday - UK week model)
    final monday = today.subtract(Duration(days: today.weekday - 1));

    // Deterministic offsets: 10 meals spread across 14 days (2 weeks)
    // Offsets: Mon(0), Tue(1), Wed(2), Thu(3), Sat(5), Sun(6), Tue(8), Thu(10), Sat(12), Sun(13)
    const offsets = [0, 1, 2, 3, 5, 6, 8, 10, 12, 13];

    int mealIdCounter = 1;

    for (final offset in offsets) {
      final date = monday.add(Duration(days: offset));
      final dateKey = _dateToKey(date);

      // Create meal with default template (will use "New Meal" title per spec)
      final meal = Meal(
        id: 'meal_$mealIdCounter',
        templateId: 'breakfast_1', // Use breakfast_1 which has "New Meal" characteristics
        date: date,
        order: 0,
        createdAt: _clock(),
      );

      _workingState.putIfAbsent(dateKey, () => []).add(meal);
      
      // Deep copy to persistent state
      _persistentState.putIfAbsent(dateKey, () => []).add(Meal(
        id: meal.id,
        templateId: meal.templateId,
        date: meal.date,
        order: meal.order,
        createdAt: meal.createdAt,
      ));

      mealIdCounter++;
    }

    _notifyListeners();
    debugPrint('[DEBUG] Seeded ${_getAllMeals().length} deterministic meals');
  }

  /// Seed a single meal for testing
  void seedMeal(Meal meal) {
    final dateKey = _dateToKey(meal.date);
    _workingState.putIfAbsent(dateKey, () => []);
    _workingState[dateKey]!.add(meal);
    _notifyListeners();
  }

  /// Clear all meals
  void clear() {
    _workingState.clear();
    _persistentState.clear();
    _notifyListeners();
  }

  /// Watch state changes
  Stream<Map<String, List<Meal>>> watchState() {
    Future.microtask(() {
      if (!_stateController.isClosed) {
        _stateController.add(Map.from(_workingState));
      }
    });
    return _stateController.stream;
  }

  @override
  List<Meal> getMealsForDate(DateTime date) {
    final dateKey = _dateToKey(date);
    return List.from(_workingState[dateKey] ?? []);
  }

  @override
  List<Meal> getMealsForDateRange(DateTime start, DateTime end) {
    final meals = <Meal>[];
    for (var date = start;
        date.isBefore(end) || date.isAtSameMomentAs(end);
        date = date.add(const Duration(days: 1))) {
      meals.addAll(getMealsForDate(date));
    }
    return meals;
  }

  @override
  Future<Meal> addMeal(DateTime date, String templateId) async {
    final dateKey = _dateToKey(date);
    _workingState.putIfAbsent(dateKey, () => []);

    final order = _workingState[dateKey]!.length;
    final now = _clock();
    final meal = Meal(
      id: 'meal_${now.millisecondsSinceEpoch}',
      templateId: templateId,
      date: date,
      order: order,
      createdAt: now,
    );

    _workingState[dateKey]!.add(meal);
    _notifyListeners();

    debugPrint('[INFO] ADD_MEAL - ${meal.toJson()}');
    return meal;
  }

  @override
  Future<void> removeMeal(String mealId) async {
    for (var dateKey in _workingState.keys) {
      final meals = _workingState[dateKey]!;
      final index = meals.indexWhere((m) => m.id == mealId);
      if (index != -1) {
        final removedMeal = meals.removeAt(index);
        // Reorder remaining meals
        for (var i = index; i < meals.length; i++) {
          meals[i] = meals[i].copyWith(order: i);
        }
        if (meals.isEmpty) {
          _workingState.remove(dateKey);
        }
        _notifyListeners();
        debugPrint('[INFO] DELETE_MEAL - ${removedMeal.toJson()}');
        return;
      }
    }
  }

  @override
  Future<void> moveMeal(String mealId, DateTime fromDate, DateTime toDate) async {
    final fromKey = _dateToKey(fromDate);
    final toKey = _dateToKey(toDate);

    if (_workingState[fromKey] == null) {
      throw Exception('No meals found on source date: $fromDate');
    }

    final meals = _workingState[fromKey]!;
    final index = meals.indexWhere((m) => m.id == mealId);
    if (index == -1) {
      throw Exception('Meal ID $mealId not found on date $fromDate');
    }

    final meal = meals.removeAt(index);

    // Reorder remaining meals in source day
    for (var i = index; i < meals.length; i++) {
      meals[i] = meals[i].copyWith(order: i);
    }
    if (meals.isEmpty) {
      _workingState.remove(fromKey);
    }

    // Add to target day
    _workingState.putIfAbsent(toKey, () => []);
    final newOrder = _workingState[toKey]!.length;
    final movedMeal = meal.copyWith(date: toDate, order: newOrder);
    _workingState[toKey]!.add(movedMeal);

    _notifyListeners();
    debugPrint('[INFO] MOVE_MEAL - from: ${fromDate.toIso8601String()}, to: ${toDate.toIso8601String()}, mealId: $mealId');
  }

  @override
  Future<void> reorderMeals(DateTime date, List<String> mealIds) async {
    final dateKey = _dateToKey(date);
    if (_workingState[dateKey] == null) {
      throw Exception('No meals found for date: $date');
    }

    final meals = _workingState[dateKey]!;
    
    // Validate all IDs exist and are from this day
    for (final id in mealIds) {
      if (!meals.any((m) => m.id == id)) {
        throw Exception('Meal ID not found or not on this date: $id');
      }
    }
    
    // Validate list completeness (all meals accounted for)
    if (mealIds.length != meals.length) {
      throw Exception('Reorder list size mismatch: expected ${meals.length}, got ${mealIds.length}');
    }

    final reordered = <Meal>[];
    for (var i = 0; i < mealIds.length; i++) {
      final meal = meals.firstWhere((m) => m.id == mealIds[i]);
      reordered.add(meal.copyWith(order: i));
    }

    _workingState[dateKey] = reordered;
    _notifyListeners();
    debugPrint('[INFO] REORDER_MEAL - date: ${date.toIso8601String()}, order: $mealIds');
  }

  @override
  Future<void> saveState(Map<String, List<Meal>> state) async {
    _persistentState.clear();
    for (var entry in state.entries) {
      _persistentState[entry.key] = List.from(entry.value);
    }
    debugPrint('[INFO] SAVE_STATE - ${_getAllMeals().length} meals persisted');
  }

  @override
  Map<String, List<Meal>> getPersistedState() {
    return Map.from(_persistentState);
  }

  @override
  void resetToPersistedState() {
    _workingState.clear();
    for (var entry in _persistentState.entries) {
      _workingState[entry.key] = List.from(entry.value);
    }
    _notifyListeners();
    debugPrint('[INFO] RESET_STATE - ${_getAllMeals().length} meals restored');
  }

  /// Get all meals (for testing)
  List<Meal> _getAllMeals() {
    final meals = <Meal>[];
    for (var dayMeals in _workingState.values) {
      meals.addAll(dayMeals);
    }
    return meals;
  }

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _notifyListeners() {
    if (!_stateController.isClosed) {
      _stateController.add(Map.from(_workingState));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
