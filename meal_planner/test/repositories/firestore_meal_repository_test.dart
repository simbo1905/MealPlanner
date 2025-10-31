import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/meal.freezed_model.dart';
import 'package:meal_planner/repositories/firestore_meal_repository.dart';
import 'package:meal_planner/repositories/meal_repository.dart';

void main() {
  const userId = 'user-123';
  late FakeFirebaseFirestore firestore;
  late MealRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreMealRepository(firestore: firestore);
  });

  group('FirestoreMealRepository', () {
    test('watchMeals emits meals scoped to user ordered by date then slot', () async {
      final dinnerDate = DateTime(2025, 10, 29);
      final lunchDate = DateTime(2025, 10, 28);

      final streamFuture = repository.watchMeals(userId).firstWhere((meals) => meals.length == 3);

      await repository.addMeal(
        userId: userId,
        date: dinnerDate,
        slot: MealSlot.dinner,
        recipeTitle: 'Salmon',
        conflictStrategy: MealConflictStrategy.keepBoth,
      );

      await repository.addMeal(
        userId: userId,
        date: dinnerDate,
        slot: MealSlot.breakfast,
        recipeTitle: 'Smoothie',
        conflictStrategy: MealConflictStrategy.keepBoth,
      );

      await repository.addMeal(
        userId: userId,
        date: lunchDate,
        slot: MealSlot.lunch,
        recipeTitle: 'Quinoa Bowl',
        conflictStrategy: MealConflictStrategy.keepBoth,
      );

      final meals = await streamFuture;

      expect(meals.map((meal) => meal.recipeTitle), ['Quinoa Bowl', 'Smoothie', 'Salmon']);
      expect(meals.every((meal) => meal.userId == userId), isTrue);
    });

    test('addMeal with replace removes existing meal in same slot', () async {
      final date = DateTime(2025, 11, 1);

      final initial = await repository.addMeal(
        userId: userId,
        date: date,
        slot: MealSlot.dinner,
        recipeTitle: 'Fish',
        conflictStrategy: MealConflictStrategy.keepBoth,
      );

      final replacement = await repository.addMeal(
        userId: userId,
        date: date,
        slot: MealSlot.dinner,
        recipeTitle: 'Burgers',
        conflictStrategy: MealConflictStrategy.replace,
      );

      final meals = await repository.watchMeals(userId).firstWhere((meals) => meals.isNotEmpty);

      expect(meals.length, 1);
      expect(meals.single.id, replacement.id);
      expect(meals.single.recipeTitle, 'Burgers');

      final doc = await firestore.collection('meals').doc(initial.id).get();
      expect(doc.exists, isFalse);
    });

    test('addMeal with keepBoth preserves existing meal in same slot', () async {
      final date = DateTime(2025, 12, 24);

      await repository.addMeal(
        userId: userId,
        date: date,
        slot: MealSlot.lunch,
        recipeTitle: 'Soup',
        conflictStrategy: MealConflictStrategy.keepBoth,
      );

      await repository.addMeal(
        userId: userId,
        date: date,
        slot: MealSlot.lunch,
        recipeTitle: 'Sandwich',
        conflictStrategy: MealConflictStrategy.keepBoth,
      );

      final meals = await repository.watchMeals(userId).firstWhere((meals) => meals.length == 2);
      final titles = meals.map((meal) => meal.recipeTitle).toList();

      expect(titles, containsAll(['Soup', 'Sandwich']));
    });

    test('updateMeal changes date, slot, and title', () async {
      final date = DateTime(2026, 1, 3);
      final meal = await repository.addMeal(
        userId: userId,
        date: date,
        slot: MealSlot.breakfast,
        recipeTitle: 'Pancakes',
        conflictStrategy: MealConflictStrategy.keepBoth,
      );

      await repository.updateMeal(
        userId: userId,
        mealId: meal.id,
        newDate: date.add(const Duration(days: 1)),
        newSlot: MealSlot.dinner,
        newRecipeTitle: 'Tacos',
      );

      final meals = await repository.watchMeals(userId).firstWhere((list) => list.single.recipeTitle == 'Tacos');
      final updated = meals.single;

      expect(updated.date, DateTime(2026, 1, 4));
      expect(updated.slot, MealSlot.dinner);
      expect(updated.recipeTitle, 'Tacos');
    });

    test('swapMeals exchanges dates and slots', () async {
      final monday = DateTime(2026, 2, 2);
      final tuesday = monday.add(const Duration(days: 1));

      final burger = await repository.addMeal(
        userId: userId,
        date: monday,
        slot: MealSlot.dinner,
        recipeTitle: 'Burger',
        conflictStrategy: MealConflictStrategy.keepBoth,
      );

      final fish = await repository.addMeal(
        userId: userId,
        date: tuesday,
        slot: MealSlot.dinner,
        recipeTitle: 'Fish',
        conflictStrategy: MealConflictStrategy.keepBoth,
      );

      await repository.swapMeals(
        userId: userId,
        firstMealId: burger.id,
        secondMealId: fish.id,
      );

      final meals = await repository.watchMeals(userId).firstWhere((list) =>
          list.any((meal) => meal.recipeTitle == 'Burger' && meal.date == tuesday) &&
          list.any((meal) => meal.recipeTitle == 'Fish' && meal.date == monday));

      final swappedBurger = meals.firstWhere((meal) => meal.id == burger.id);
      final swappedFish = meals.firstWhere((meal) => meal.id == fish.id);

      expect(swappedBurger.date, tuesday);
      expect(swappedFish.date, monday);
      expect(swappedBurger.slot, MealSlot.dinner);
      expect(swappedFish.slot, MealSlot.dinner);
    });

    test('deleteMeal removes document and stops emitting it', () async {
      final meal = await repository.addMeal(
        userId: userId,
        date: DateTime(2026, 3, 10),
        slot: MealSlot.other,
        recipeTitle: 'Leftovers',
        conflictStrategy: MealConflictStrategy.keepBoth,
      );

      await repository.deleteMeal(userId: userId, mealId: meal.id);

      final meals = await repository.watchMeals(userId).first;
      expect(meals, isEmpty);

      final doc = await firestore.collection('meals').doc(meal.id).get();
      expect(doc.exists, isFalse);
    });

    test('findMealByDateSlot returns matching meal or null', () async {
      final date = DateTime(2026, 4, 15);
      await repository.addMeal(
        userId: userId,
        date: date,
        slot: MealSlot.breakfast,
        recipeTitle: 'Waffles',
        conflictStrategy: MealConflictStrategy.keepBoth,
      );

      final found = await repository.findMealByDateSlot(
        userId: userId,
        date: date,
        slot: MealSlot.breakfast,
      );

      final missing = await repository.findMealByDateSlot(
        userId: userId,
        date: date,
        slot: MealSlot.dinner,
      );

      expect(found, isNotNull);
      expect(found!.recipeTitle, 'Waffles');
      expect(missing, isNull);
    });
  });
}