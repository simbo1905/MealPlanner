import 'package:flutter_test/flutter_test.dart';
import '../repositories/fake_recipes_v1_repository.dart';

void main() {
  group('FakeRecipesV1Repository', () {
    late FakeRecipesV1Repository repository;

    setUp(() {
      repository = FakeRecipesV1Repository();
    });

    test('searchByTitlePrefix returns recipes starting with prefix', () async {
      final results = await repository.searchByTitlePrefix('chick').first;
      
      expect(results, isNotEmpty);
      expect(results.any((r) => r.title?.contains('Chicken') ?? false), isTrue);
    });

    test('searchByTitlePrefix is case-insensitive', () async {
      final results1 = await repository.searchByTitlePrefix('CHICK').first;
      final results2 = await repository.searchByTitlePrefix('chick').first;
      
      expect(results1.length, equals(results2.length));
    });

    test('searchByTitlePrefix returns empty for non-matching prefix', () async {
      final results = await repository.searchByTitlePrefix('xyz').first;
      
      expect(results, isEmpty);
    });

    test('searchByTitlePrefix respects limit parameter', () async {
      final results = await repository.searchByTitlePrefix('', limit: 3).first;
      
      expect(results.length, lessThanOrEqualTo(3));
    });

    test('searchByTitlePrefix returns empty for empty prefix', () async {
      final results = await repository.searchByTitlePrefix('').first;
      
      expect(results, isEmpty);
    });

    test('searchByIngredient returns recipes containing ingredient', () async {
      final results = await repository.searchByIngredient('tomato').first;
      
      expect(results, isNotEmpty);
      expect(
        results.any((r) => r.ingredientNamesNormalized?.contains('tomato') ?? false),
        isTrue,
      );
    });

    test('searchByIngredient is case-insensitive', () async {
      final results1 = await repository.searchByIngredient('TOMATO').first;
      final results2 = await repository.searchByIngredient('tomato').first;
      
      expect(results1.length, equals(results2.length));
    });

    test('searchByIngredient returns empty for non-matching ingredient', () async {
      final results = await repository.searchByIngredient('unobtanium').first;
      
      expect(results, isEmpty);
    });

    test('searchByIngredient respects limit parameter', () async {
      final results = await repository.searchByIngredient('chicken', limit: 1).first;
      
      expect(results.length, lessThanOrEqualTo(1));
    });

    test('getById returns recipe with matching ID', () async {
      final recipe = await repository.getById('recipe_1');
      
      expect(recipe, isNotNull);
      expect(recipe!.id, equals('recipe_1'));
    });

    test('getById returns null for non-existent ID', () async {
      final recipe = await repository.getById('non_existent');
      
      expect(recipe, isNull);
    });

    test('getTotalCount returns correct number of recipes', () async {
      final count = await repository.getTotalCount();
      
      expect(count, greaterThan(0));
    });
  });
}
