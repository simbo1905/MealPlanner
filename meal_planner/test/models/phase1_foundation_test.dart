import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/meal.freezed_model.dart';
import 'package:meal_planner/models/meal_template.freezed_model.dart';
import 'package:meal_planner/models/week_section.freezed_model.dart';
import '../repositories/fake_meal_repository.dart';
import '../repositories/fake_meal_template_repository.dart';

void main() {
  group('Phase 1: Foundation Models & Repositories', () {
    late FakeMealRepository mealRepo;
    late FakeMealTemplateRepository templateRepo;
    late DateTime Function() testClock;

    setUp(() {
      // Use fixed date for deterministic testing
      final fixedNow = DateTime(2025, 10, 28, 10, 0, 0);
      testClock = () => fixedNow;
      
      mealRepo = FakeMealRepository(clock: testClock);
      templateRepo = FakeMealTemplateRepository();
    });

    tearDown(() {
      mealRepo.dispose();
    });

    test('Meal model creates instance with required fields', () {
      final now = DateTime.now();
      final meal = Meal(
        id: 'test_1',
        templateId: 'breakfast_1',
        date: now,
        order: 0,
        createdAt: now,
      );

      expect(meal.id, 'test_1');
      expect(meal.templateId, 'breakfast_1');
      expect(meal.date, now);
      expect(meal.order, 0);
      expect(meal.createdAt, now);
    });

    test('MealTemplate model has all required fields', () {
      final template = MealTemplate(
        templateId: 'test_template',
        title: 'Test Meal',
        type: MealType.breakfast,
        prepTimeMinutes: 10,
        iconName: 'test_icon',
        colorHex: '#FF0000',
      );

      expect(template.templateId, 'test_template');
      expect(template.title, 'Test Meal');
      expect(template.type, MealType.breakfast);
      expect(template.prepTimeMinutes, 10);
      expect(template.iconName, 'test_icon');
      expect(template.colorHex, '#FF0000');
    });

    test('WeekSection model creates with days', () {
      final now = DateTime.now();
      final weekSection = WeekSection(
        weekStart: now,
        weekEnd: now.add(const Duration(days: 6)),
        weekNumber: 1,
        days: [],
        totalMeals: 0,
        totalPrepTime: 0,
      );

      expect(weekSection.weekNumber, 1);
      expect(weekSection.days, isEmpty);
      expect(weekSection.totalMeals, 0);
    });

    test('DaySection model creates with meals list', () {
      final now = DateTime.now();
      final daySection = DaySection(
        date: now,
        dayLabel: 'MON',
        isToday: true,
        isSelected: false,
        meals: [],
      );

      expect(daySection.dayLabel, 'MON');
      expect(daySection.isToday, true);
      expect(daySection.isSelected, false);
      expect(daySection.meals, isEmpty);
    });

    test('FakeMealTemplateRepository returns all 10 demo templates', () {
      final templates = templateRepo.getAllTemplates();

      expect(templates.length, 10);
      expect(templates[0].templateId, 'breakfast_1');
      expect(templates[0].title, 'Oatmeal');
      expect(templates[9].templateId, 'supper_2');
      expect(templates[9].title, 'Herbal Tea');
    });

    test('FakeMealTemplateRepository finds template by ID', () {
      final template = templateRepo.getTemplateById('lunch_1');

      expect(template, isNotNull);
      expect(template!.title, 'Chicken Salad');
      expect(template.type, MealType.lunch);
      expect(template.prepTimeMinutes, 20);
    });

    test('FakeMealTemplateRepository returns null for invalid ID', () {
      final template = templateRepo.getTemplateById('invalid_id');

      expect(template, isNull);
    });

    test('FakeMealRepository starts empty', () {
      final meals = mealRepo.getMealsForDate(DateTime.now());

      expect(meals, isEmpty);
    });

    test('FakeMealRepository adds meal to date', () async {
      final date = DateTime.now();
      final meal = await mealRepo.addMeal(date, 'breakfast_1');

      expect(meal.templateId, 'breakfast_1');
      expect(meal.order, 0);

      final mealsForDate = mealRepo.getMealsForDate(date);
      expect(mealsForDate.length, 1);
      expect(mealsForDate[0].id, meal.id);
    });

    test('FakeMealRepository removes meal', () async {
      final date = DateTime.now();
      final meal = await mealRepo.addMeal(date, 'breakfast_1');

      await mealRepo.removeMeal(meal.id);

      final mealsForDate = mealRepo.getMealsForDate(date);
      expect(mealsForDate, isEmpty);
    });

    test('FakeMealRepository reorders meals on remove', () async {
      final date = DateTime.now();
      final meal1 = await mealRepo.addMeal(date, 'breakfast_1');
      final meal2 = await mealRepo.addMeal(date, 'lunch_1');
      final meal3 = await mealRepo.addMeal(date, 'dinner_1');

      await mealRepo.removeMeal(meal2.id);

      final meals = mealRepo.getMealsForDate(date);
      expect(meals.length, 2);
      expect(meals[0].id, meal1.id);
      expect(meals[0].order, 0);
      expect(meals[1].id, meal3.id);
      expect(meals[1].order, 1);
    });

    test('FakeMealRepository moves meal between dates', () async {
      final date1 = DateTime.now();
      final date2 = date1.add(const Duration(days: 1));
      final meal = await mealRepo.addMeal(date1, 'breakfast_1');

      await mealRepo.moveMeal(meal.id, date1, date2);

      final mealsDate1 = mealRepo.getMealsForDate(date1);
      final mealsDate2 = mealRepo.getMealsForDate(date2);

      expect(mealsDate1, isEmpty);
      expect(mealsDate2.length, 1);
      expect(mealsDate2[0].templateId, 'breakfast_1');
    });

    test('FakeMealRepository seeds demo meals with correct pattern', () {
      mealRepo.seedDemoMeals();

      // Should seed exactly 10 meals across 14 days
      final now = testClock();
      final today = DateTime(now.year, now.month, now.day);
      final monday = today.subtract(Duration(days: today.weekday - 1));

      // Expected offsets: [0, 1, 2, 3, 5, 6, 8, 10, 12, 13]
      // This means: Mon(1), Tue(1), Wed(1), Thu(1), Sat(1), Sun(1), Tue(1), Thu(1), Sat(1), Sun(1)
      final expected = {
        0: 1,  // Monday
        1: 1,  // Tuesday (week 1)
        2: 1,  // Wednesday
        3: 1,  // Thursday (week 1)
        4: 0,  // Friday (week 1)
        5: 1,  // Saturday (week 1)
        6: 1,  // Sunday (week 1)
        7: 0,  // Monday (week 2)
        8: 1,  // Tuesday (week 2)
        9: 0,  // Wednesday (week 2)
        10: 1, // Thursday (week 2)
        11: 0, // Friday (week 2)
        12: 1, // Saturday (week 2)
        13: 1, // Sunday (week 2)
      };

      int totalCount = 0;
      for (int i = 0; i < 14; i++) {
        final date = monday.add(Duration(days: i));
        final meals = mealRepo.getMealsForDate(date);
        expect(meals.length, expected[i]!,
            reason: 'Day $i should have ${expected[i]} meals');
        totalCount += meals.length;
      }

      expect(totalCount, 10, reason: 'Total should be exactly 10 meals');
    });

    test('FakeMealRepository saves and resets state', () async {
      final date = DateTime.now();
      await mealRepo.addMeal(date, 'breakfast_1');
      await mealRepo.addMeal(date, 'lunch_1');

      final workingState = {
        mealRepo.getMealsForDate(date)[0].date.toIso8601String().split('T')[0]:
            mealRepo.getMealsForDate(date)
      };
      await mealRepo.saveState(workingState);

      await mealRepo.addMeal(date, 'dinner_1');
      expect(mealRepo.getMealsForDate(date).length, 3);

      mealRepo.resetToPersistedState();
      expect(mealRepo.getMealsForDate(date).length, 2);
    });

    test('FakeMealRepository gets meals for date range', () async {
      final date1 = DateTime.now();
      final date2 = date1.add(const Duration(days: 1));
      final date3 = date1.add(const Duration(days: 2));

      await mealRepo.addMeal(date1, 'breakfast_1');
      await mealRepo.addMeal(date2, 'lunch_1');
      await mealRepo.addMeal(date3, 'dinner_1');

      final meals = mealRepo.getMealsForDateRange(date1, date2);
      expect(meals.length, 2);
    });
  });
}
