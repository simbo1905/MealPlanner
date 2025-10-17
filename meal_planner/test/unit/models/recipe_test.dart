import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/recipe.dart';
import 'package:meal_planner/models/ingredient.dart';

void main() {
  group('MealType enum', () {
    test('should have all meal types', () {
      expect(MealType.values.length, 6);
      expect(MealType.values.contains(MealType.breakfast), true);
      expect(MealType.values.contains(MealType.brunch), true);
      expect(MealType.values.contains(MealType.lunch), true);
      expect(MealType.values.contains(MealType.dinner), true);
      expect(MealType.values.contains(MealType.snack), true);
      expect(MealType.values.contains(MealType.dessert), true);
    });

    test('should convert to/from string', () {
      expect(mealTypeToString(MealType.breakfast), 'breakfast');
      expect(mealTypeToString(MealType.dinner), 'dinner');
      expect(mealTypeFromString('breakfast'), MealType.breakfast);
      expect(mealTypeFromString('dinner'), MealType.dinner);
    });
  });

  group('Recipe model', () {
    final testIngredient = Ingredient(
      name: 'Flour',
      ucumUnit: UcumUnit.cupUs,
      ucumAmount: 2.0,
      metricUnit: MetricUnit.g,
      metricAmount: 250.0,
      notes: 'All-purpose flour',
    );

    test('should create valid recipe without UUID', () {
      final recipe = Recipe(
        title: 'Pancakes',
        imageUrl: 'https://example.com/pancakes.jpg',
        description: 'Fluffy pancakes',
        notes: 'Best served hot',
        preReqs: ['Mix dry ingredients', 'Mix wet ingredients'],
        totalTime: 30.0,
        ingredients: [testIngredient],
        steps: ['Combine ingredients', 'Cook on griddle'],
      );

      expect(recipe.uuid, null);
      expect(recipe.title, 'Pancakes');
      expect(recipe.imageUrl, 'https://example.com/pancakes.jpg');
      expect(recipe.description, 'Fluffy pancakes');
      expect(recipe.notes, 'Best served hot');
      expect(recipe.preReqs.length, 2);
      expect(recipe.totalTime, 30.0);
      expect(recipe.ingredients.length, 1);
      expect(recipe.steps.length, 2);
      expect(recipe.mealType, null);
    });

    test('should create recipe with UUID and meal type', () {
      final recipe = Recipe(
        uuid: '12345-67890',
        title: 'Breakfast Burrito',
        imageUrl: 'https://example.com/burrito.jpg',
        description: 'Hearty breakfast',
        notes: '',
        preReqs: [],
        totalTime: 15.0,
        ingredients: [testIngredient],
        steps: ['Scramble eggs', 'Wrap in tortilla'],
        mealType: MealType.breakfast,
      );

      expect(recipe.uuid, '12345-67890');
      expect(recipe.mealType, MealType.breakfast);
    });

    test('should serialize to JSON', () {
      final recipe = Recipe(
        uuid: 'test-uuid',
        title: 'Test Recipe',
        imageUrl: 'https://example.com/test.jpg',
        description: 'Test description',
        notes: 'Test notes',
        preReqs: ['Prep step'],
        totalTime: 45.0,
        ingredients: [testIngredient],
        steps: ['Cook step'],
        mealType: MealType.lunch,
      );

      final json = recipe.toJson();
      expect(json['uuid'], 'test-uuid');
      expect(json['title'], 'Test Recipe');
      expect(json['image_url'], 'https://example.com/test.jpg');
      expect(json['description'], 'Test description');
      expect(json['notes'], 'Test notes');
      expect(json['pre_reqs'], ['Prep step']);
      expect(json['total_time'], 45.0);
      expect(json['ingredients'], isA<List>());
      expect(json['steps'], ['Cook step']);
      expect(json['meal_type'], 'lunch');
    });

    test('should deserialize from JSON', () {
      final json = {
        'uuid': 'json-uuid',
        'title': 'JSON Recipe',
        'image_url': 'https://example.com/json.jpg',
        'description': 'From JSON',
        'notes': 'JSON notes',
        'pre_reqs': ['JSON prep'],
        'total_time': 60.0,
        'ingredients': [testIngredient.toJson()],
        'steps': ['JSON step'],
        'meal_type': 'dinner',
      };

      final recipe = Recipe.fromJson(json);
      expect(recipe.uuid, 'json-uuid');
      expect(recipe.title, 'JSON Recipe');
      expect(recipe.imageUrl, 'https://example.com/json.jpg');
      expect(recipe.description, 'From JSON');
      expect(recipe.notes, 'JSON notes');
      expect(recipe.preReqs, ['JSON prep']);
      expect(recipe.totalTime, 60.0);
      expect(recipe.ingredients.length, 1);
      expect(recipe.steps, ['JSON step']);
      expect(recipe.mealType, MealType.dinner);
    });

    test('should handle JSON without optional fields', () {
      final json = {
        'title': 'Minimal Recipe',
        'image_url': 'https://example.com/minimal.jpg',
        'description': 'Minimal',
        'notes': '',
        'pre_reqs': [],
        'total_time': 10.0,
        'ingredients': [testIngredient.toJson()],
        'steps': ['Simple step'],
      };

      final recipe = Recipe.fromJson(json);
      expect(recipe.uuid, null);
      expect(recipe.mealType, null);
    });

    test('should support equality', () {
      final recipe1 = Recipe(
        uuid: 'same-uuid',
        title: 'Same Recipe',
        imageUrl: 'https://example.com/same.jpg',
        description: 'Same',
        notes: '',
        preReqs: [],
        totalTime: 20.0,
        ingredients: [testIngredient],
        steps: ['Step'],
      );

      final recipe2 = Recipe(
        uuid: 'same-uuid',
        title: 'Same Recipe',
        imageUrl: 'https://example.com/same.jpg',
        description: 'Same',
        notes: '',
        preReqs: [],
        totalTime: 20.0,
        ingredients: [testIngredient],
        steps: ['Step'],
      );

      final recipe3 = Recipe(
        uuid: 'different-uuid',
        title: 'Different Recipe',
        imageUrl: 'https://example.com/diff.jpg',
        description: 'Different',
        notes: '',
        preReqs: [],
        totalTime: 30.0,
        ingredients: [testIngredient],
        steps: ['Different step'],
      );

      expect(recipe1, equals(recipe2));
      expect(recipe1, isNot(equals(recipe3)));
      expect(recipe1.hashCode, equals(recipe2.hashCode));
    });

    test('should support copyWith', () {
      final original = Recipe(
        uuid: 'original-uuid',
        title: 'Original',
        imageUrl: 'https://example.com/original.jpg',
        description: 'Original desc',
        notes: 'Original notes',
        preReqs: ['Original prep'],
        totalTime: 40.0,
        ingredients: [testIngredient],
        steps: ['Original step'],
      );

      final modified = original.copyWith(
        title: 'Modified',
        totalTime: 50.0,
      );

      expect(modified.uuid, 'original-uuid');
      expect(modified.title, 'Modified');
      expect(modified.totalTime, 50.0);
      expect(modified.imageUrl, 'https://example.com/original.jpg');
      expect(modified.description, 'Original desc');
    });

    test('should validate minimum ingredients requirement', () {
      expect(
        () => Recipe(
          title: 'Invalid',
          imageUrl: 'https://example.com/invalid.jpg',
          description: 'No ingredients',
          notes: '',
          preReqs: [],
          totalTime: 10.0,
          ingredients: [],
          steps: ['Step'],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should validate minimum steps requirement', () {
      expect(
        () => Recipe(
          title: 'Invalid',
          imageUrl: 'https://example.com/invalid.jpg',
          description: 'No steps',
          notes: '',
          preReqs: [],
          totalTime: 10.0,
          ingredients: [testIngredient],
          steps: [],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
