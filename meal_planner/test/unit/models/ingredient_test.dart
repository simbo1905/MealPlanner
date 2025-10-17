import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/ingredient.dart';

void main() {
  group('UcumUnit enum', () {
    test('should have all required units', () {
      expect(UcumUnit.values.length, 9);
      expect(UcumUnit.values.contains(UcumUnit.cupUs), true);
      expect(UcumUnit.values.contains(UcumUnit.cupM), true);
      expect(UcumUnit.values.contains(UcumUnit.cupImp), true);
      expect(UcumUnit.values.contains(UcumUnit.tbspUs), true);
      expect(UcumUnit.values.contains(UcumUnit.tbspM), true);
      expect(UcumUnit.values.contains(UcumUnit.tbspImp), true);
      expect(UcumUnit.values.contains(UcumUnit.tspUs), true);
      expect(UcumUnit.values.contains(UcumUnit.tspM), true);
      expect(UcumUnit.values.contains(UcumUnit.tspImp), true);
    });

    test('should convert to/from string', () {
      expect(ucumUnitToString(UcumUnit.cupUs), 'cup_us');
      expect(ucumUnitToString(UcumUnit.tbspM), 'tbsp_m');
      expect(ucumUnitFromString('cup_us'), UcumUnit.cupUs);
      expect(ucumUnitFromString('tbsp_m'), UcumUnit.tbspM);
    });
  });

  group('MetricUnit enum', () {
    test('should have ml and g', () {
      expect(MetricUnit.values.length, 2);
      expect(MetricUnit.values.contains(MetricUnit.ml), true);
      expect(MetricUnit.values.contains(MetricUnit.g), true);
    });

    test('should convert to/from string', () {
      expect(metricUnitToString(MetricUnit.ml), 'ml');
      expect(metricUnitToString(MetricUnit.g), 'g');
      expect(metricUnitFromString('ml'), MetricUnit.ml);
      expect(metricUnitFromString('g'), MetricUnit.g);
    });
  });

  group('AllergenCode enum', () {
    test('should have all EU regulation allergens', () {
      expect(AllergenCode.values.length, 17);
      expect(AllergenCode.values.contains(AllergenCode.gluten), true);
      expect(AllergenCode.values.contains(AllergenCode.crustacean), true);
      expect(AllergenCode.values.contains(AllergenCode.egg), true);
    });

    test('should convert to/from string', () {
      expect(allergenCodeToString(AllergenCode.gluten), 'GLUTEN');
      expect(allergenCodeToString(AllergenCode.peanut), 'PEANUT');
      expect(allergenCodeFromString('GLUTEN'), AllergenCode.gluten);
      expect(allergenCodeFromString('PEANUT'), AllergenCode.peanut);
    });
  });

  group('Ingredient model', () {
    test('should create valid ingredient', () {
      final ingredient = Ingredient(
        name: 'Flour',
        ucumUnit: UcumUnit.cupUs,
        ucumAmount: 2.5,
        metricUnit: MetricUnit.g,
        metricAmount: 300.0,
        notes: 'All-purpose',
      );

      expect(ingredient.name, 'Flour');
      expect(ingredient.ucumUnit, UcumUnit.cupUs);
      expect(ingredient.ucumAmount, 2.5);
      expect(ingredient.metricUnit, MetricUnit.g);
      expect(ingredient.metricAmount, 300.0);
      expect(ingredient.notes, 'All-purpose');
      expect(ingredient.allergenCode, null);
    });

    test('should create ingredient with allergen', () {
      final ingredient = Ingredient(
        name: 'Milk',
        ucumUnit: UcumUnit.cupUs,
        ucumAmount: 1.0,
        metricUnit: MetricUnit.ml,
        metricAmount: 250.0,
        notes: 'Whole milk',
        allergenCode: AllergenCode.milk,
      );

      expect(ingredient.allergenCode, AllergenCode.milk);
    });

    test('should serialize to JSON', () {
      final ingredient = Ingredient(
        name: 'Eggs',
        ucumUnit: UcumUnit.cupUs,
        ucumAmount: 0.5,
        metricUnit: MetricUnit.g,
        metricAmount: 100.0,
        notes: 'Large eggs',
        allergenCode: AllergenCode.egg,
      );

      final json = ingredient.toJson();
      expect(json['name'], 'Eggs');
      expect(json['ucum-unit'], 'cup_us');
      expect(json['ucum-amount'], 0.5);
      expect(json['metric-unit'], 'g');
      expect(json['metric-amount'], 100.0);
      expect(json['notes'], 'Large eggs');
      expect(json['allergen-code'], 'EGG');
    });

    test('should deserialize from JSON', () {
      final json = {
        'name': 'Butter',
        'ucum-unit': 'tbsp_us',
        'ucum-amount': 4.0,
        'metric-unit': 'g',
        'metric-amount': 56.0,
        'notes': 'Unsalted',
        'allergen-code': 'MILK',
      };

      final ingredient = Ingredient.fromJson(json);
      expect(ingredient.name, 'Butter');
      expect(ingredient.ucumUnit, UcumUnit.tbspUs);
      expect(ingredient.ucumAmount, 4.0);
      expect(ingredient.metricUnit, MetricUnit.g);
      expect(ingredient.metricAmount, 56.0);
      expect(ingredient.notes, 'Unsalted');
      expect(ingredient.allergenCode, AllergenCode.milk);
    });

    test('should handle JSON without allergen', () {
      final json = {
        'name': 'Salt',
        'ucum-unit': 'tsp_us',
        'ucum-amount': 1.0,
        'metric-unit': 'g',
        'metric-amount': 6.0,
        'notes': 'Sea salt',
      };

      final ingredient = Ingredient.fromJson(json);
      expect(ingredient.allergenCode, null);
    });

    test('should support equality', () {
      final ing1 = Ingredient(
        name: 'Sugar',
        ucumUnit: UcumUnit.cupUs,
        ucumAmount: 1.0,
        metricUnit: MetricUnit.g,
        metricAmount: 200.0,
        notes: 'White sugar',
      );

      final ing2 = Ingredient(
        name: 'Sugar',
        ucumUnit: UcumUnit.cupUs,
        ucumAmount: 1.0,
        metricUnit: MetricUnit.g,
        metricAmount: 200.0,
        notes: 'White sugar',
      );

      final ing3 = Ingredient(
        name: 'Brown Sugar',
        ucumUnit: UcumUnit.cupUs,
        ucumAmount: 1.0,
        metricUnit: MetricUnit.g,
        metricAmount: 200.0,
        notes: 'Dark',
      );

      expect(ing1, equals(ing2));
      expect(ing1, isNot(equals(ing3)));
      expect(ing1.hashCode, equals(ing2.hashCode));
    });

    test('should support copyWith', () {
      final original = Ingredient(
        name: 'Olive Oil',
        ucumUnit: UcumUnit.tbspUs,
        ucumAmount: 2.0,
        metricUnit: MetricUnit.ml,
        metricAmount: 30.0,
        notes: 'Extra virgin',
      );

      final modified = original.copyWith(ucumAmount: 4.0, metricAmount: 60.0);
      expect(modified.name, 'Olive Oil');
      expect(modified.ucumAmount, 4.0);
      expect(modified.metricAmount, 60.0);
      expect(modified.notes, 'Extra virgin');
    });
  });
}
