import 'dart:async';

import 'package:meal_planner/models/meal.freezed_model.dart';
import 'meal_repository.dart';

class InMemoryMealRepository implements MealRepository {
  InMemoryMealRepository({DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    _persistedMeals = List.from(_meals);
  }

  final DateTime Function() _clock;
  final _mealsStream = StreamController<List<Meal>>.broadcast();

  final List<Meal> _meals = [];
  List<Meal> _persistedMeals = [];

  void _emit(String userId) {
    _mealsStream.add(_meals.where((m) => m.userId == userId).toList()
      ..sort((a, b) {
        final cmp = a.date.compareTo(b.date);
        if (cmp != 0) return cmp;
        return a.slot.index.compareTo(b.slot.index);
      }));
  }

  // Demo seeding used by UI/tests
  void seedDemoMeals() {
    final now = _clock();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    const offsets = [0, 1, 2, 3, 5, 6, 8, 10, 12, 13];
    const titles = [
      'Pancakes', 'Salad', 'Pasta', 'Curry', 'Soup',
      'Tacos', 'Burger', 'Stir Fry', 'Fish', 'Pizza'
    ];
    for (var i = 0; i < offsets.length; i++) {
      final date = monday.add(Duration(days: offsets[i]));
      final id = 'demo-${date.toIso8601String()}-$i';
      _meals.add(Meal(
        id: id,
        recipeTitle: titles[i % titles.length],
        date: DateTime(date.year, date.month, date.day),
        slot: MealSlot.values[i % MealSlot.values.length],
        userId: 'demo-user',
        createdAt: _clock(),
      ));
    }
    _persistedMeals = List.from(_meals);
    _emit('demo-user');
  }

  // Legacy UI API
  @override
  List<Meal> getMealsForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return _meals.where((m) => m.date == d).toList();
  }

  @override
  List<Meal> getMealsForDateRange(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return _meals.where((m) => m.date.isAtSameMomentAs(s) || m.date.isAfter(s))
        .where((m) => m.date.isAtSameMomentAs(e) || m.date.isBefore(e))
        .toList();
  }

  @override
  Future<void> saveState(Map<String, List<Meal>> state) async {
    _meals
      ..clear()
      ..addAll(state.entries.expand((e) => e.value));
    _persistedMeals = List.from(_meals);
    _emit('demo-user');
  }

  @override
  void resetToPersistedState() {
    _meals
      ..clear()
      ..addAll(_persistedMeals);
    _emit('demo-user');
  }

  // New API
  @override
  Stream<List<Meal>> watchMeals(String userId) => _mealsStream.stream;

  @override
  Future<Meal> addMeal({
    required String userId,
    required DateTime date,
    required MealSlot slot,
    required String recipeTitle,
    MealConflictStrategy conflictStrategy = MealConflictStrategy.keepBoth,
  }) async {
    if (conflictStrategy == MealConflictStrategy.replace) {
      _meals.removeWhere((m) => m.userId == userId && _sameDay(m.date, date) && m.slot == slot);
    }
    final id = 'mem-${_meals.length + 1}';
    final meal = Meal(
      id: id,
      recipeTitle: recipeTitle,
      date: DateTime(date.year, date.month, date.day),
      slot: slot,
      userId: userId,
      createdAt: _clock(),
    );
    _meals.add(meal);
    _emit(userId);
    return meal;
  }

  @override
  Future<void> deleteMeal({required String userId, required String mealId}) async {
    _meals.removeWhere((m) => m.userId == userId && m.id == mealId);
    _emit(userId);
  }

  @override
  Future<void> updateMeal({
    required String userId,
    required String mealId,
    DateTime? newDate,
    MealSlot? newSlot,
    String? newRecipeTitle,
  }) async {
    final idx = _meals.indexWhere((m) => m.userId == userId && m.id == mealId);
    if (idx == -1) return;
    var meal = _meals[idx];
    if (newDate != null) {
      meal = meal.copyWith(date: DateTime(newDate.year, newDate.month, newDate.day));
    }
    if (newSlot != null) {
      meal = meal.copyWith(slot: newSlot);
    }
    if (newRecipeTitle != null) {
      meal = meal.copyWith(recipeTitle: newRecipeTitle);
    }
    _meals[idx] = meal;
    _emit(userId);
  }

  @override
  Future<void> swapMeals({
    required String userId,
    required String firstMealId,
    required String secondMealId,
  }) async {
    final aIdx = _meals.indexWhere((m) => m.userId == userId && m.id == firstMealId);
    final bIdx = _meals.indexWhere((m) => m.userId == userId && m.id == secondMealId);
    if (aIdx == -1 || bIdx == -1) return;
    final a = _meals[aIdx];
    final b = _meals[bIdx];
    _meals[aIdx] = a.copyWith(date: b.date, slot: b.slot);
    _meals[bIdx] = b.copyWith(date: a.date, slot: a.slot);
    _emit(userId);
  }

  @override
  Future<Meal?> findMealByDateSlot({
    required String userId,
    required DateTime date,
    required MealSlot slot,
  }) async {
    for (final m in _meals) {
      if (m.userId == userId && _sameDay(m.date, date) && m.slot == slot) {
        return m;
      }
    }
    return null;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
