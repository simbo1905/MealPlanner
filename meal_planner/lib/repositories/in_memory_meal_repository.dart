import 'dart:async';

import '../models/meal.freezed_model.dart';
import 'meal_repository.dart';

class InMemoryMealRepository implements MealRepository {
  InMemoryMealRepository({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  final Map<String, List<Meal>> _mealsByUser = {};
  final Map<String, StreamController<List<Meal>>> _controllers = {};
  int _idCounter = 0;

  // Helpers
  List<Meal> _listFor(String userId) => _mealsByUser.putIfAbsent(userId, () => []);
  StreamController<List<Meal>> _controllerFor(String userId) {
    if (_controllers.containsKey(userId)) return _controllers[userId]!;
    late final StreamController<List<Meal>> c;
    c = StreamController<List<Meal>>.broadcast(onListen: () {
      final list = [..._listFor(userId)]
        ..sort((a, b) {
          final dateCmp = a.date.compareTo(b.date);
          if (dateCmp != 0) return dateCmp;
          return a.slot.index.compareTo(b.slot.index);
        });
      c.add(list);
    });
    _controllers[userId] = c;
    return c;
  }

  void _emit(String userId) {
    final list = [..._listFor(userId)]
      ..sort((a, b) {
        final dateCmp = a.date.compareTo(b.date);
        if (dateCmp != 0) return dateCmp;
        return a.slot.index.compareTo(b.slot.index);
      });
    _controllerFor(userId).add(list);
  }

  String _nextId() => (++_idCounter).toString();

  // Public API
  @override
  Stream<List<Meal>> watchMeals(String userId) {
    final c = _controllerFor(userId);
    // Ensure an initial snapshot is emitted for newly attached listeners.
    Future.microtask(() => _emit(userId));
    return c.stream;
  }

  @override
  Future<Meal> addMeal({
    required String userId,
    required DateTime date,
    required MealSlot slot,
    required String recipeTitle,
    MealConflictStrategy conflictStrategy = MealConflictStrategy.keepBoth,
  }) async {
    final list = _listFor(userId);
    if (conflictStrategy == MealConflictStrategy.replace) {
      list.removeWhere((m) => _isSameDay(m.date, date) && m.slot == slot);
    }
    final meal = Meal(
      id: _nextId(),
      recipeTitle: recipeTitle,
      date: DateTime(date.year, date.month, date.day),
      slot: slot,
      userId: userId,
      createdAt: _clock(),
    );
    list.add(meal);
    _emit(userId);
    return meal;
  }

  @override
  Future<void> deleteMeal({required String userId, required String mealId}) async {
    _listFor(userId).removeWhere((m) => m.id == mealId);
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
    final list = _listFor(userId);
    final idx = list.indexWhere((m) => m.id == mealId);
    if (idx == -1) return;
    var meal = list[idx];
    meal = meal.copyWith(
      date: newDate != null ? DateTime(newDate.year, newDate.month, newDate.day) : meal.date,
      slot: newSlot ?? meal.slot,
      recipeTitle: newRecipeTitle ?? meal.recipeTitle,
    );
    list[idx] = meal;
    _emit(userId);
  }

  @override
  Future<void> swapMeals({
    required String userId,
    required String firstMealId,
    required String secondMealId,
  }) async {
    final list = _listFor(userId);
    final aIdx = list.indexWhere((m) => m.id == firstMealId);
    final bIdx = list.indexWhere((m) => m.id == secondMealId);
    if (aIdx == -1 || bIdx == -1) return;
    final a = list[aIdx];
    final b = list[bIdx];
    list[aIdx] = a.copyWith(date: b.date, slot: b.slot);
    list[bIdx] = b.copyWith(date: a.date, slot: a.slot);
    _emit(userId);
  }

  @override
  Future<Meal?> findMealByDateSlot({
    required String userId,
    required DateTime date,
    required MealSlot slot,
  }) async {
    for (final m in _listFor(userId)) {
      if (_isSameDay(m.date, date) && m.slot == slot) {
        return m;
      }
    }
    return null;
  }

  // Legacy helpers used by some UI code
  static const _defaultUser = 'integration-test-user';

  @override
  List<Meal> getMealsForDate(DateTime date) {
    return _listFor(_defaultUser)
        .where((m) => _isSameDay(m.date, date))
        .toList()
      ..sort((a, b) => a.slot.index.compareTo(b.slot.index));
  }

  @override
  List<Meal> getMealsForDateRange(DateTime start, DateTime end) {
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);
    return _listFor(_defaultUser).where((m) {
      final d = DateTime(m.date.year, m.date.month, m.date.day);
      return !d.isBefore(startOnly) && !d.isAfter(endOnly);
    }).toList();
  }

  @override
  Future<void> saveState(Map<String, List<Meal>> state) async {}

  @override
  void resetToPersistedState() {}

  // Deterministic seeding for tests (10 meals over 14 days)
  void seedDemoMeals({String userId = _defaultUser}) {
    final baseMonday = _mondayOfWeek(_clock());
    const offsets = [0, 1, 2, 3, 5, 6, 8, 10, 12, 13];
    for (var i = 0; i < offsets.length; i++) {
      final date = baseMonday.add(Duration(days: offsets[i]));
      final slot = MealSlot.values[i % MealSlot.values.length];
      _listFor(userId).add(
        Meal(
          id: _nextId(),
          recipeTitle: 'Demo Meal ${i + 1}',
          date: DateTime(date.year, date.month, date.day),
          slot: slot,
          userId: userId,
          createdAt: _clock(),
        ),
      );
    }
    _emit(userId);
  }

  // Utils
  DateTime _mondayOfWeek(DateTime d) => d.subtract(Duration(days: d.weekday - 1));
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
