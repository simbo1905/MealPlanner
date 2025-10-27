import 'package:flutter/foundation.dart';
import 'enums.dart';

@immutable
class Ingredient {
  final String name;
  final UcumUnit ucumUnit;
  final double ucumAmount;
  final MetricUnit metricUnit;
  final double metricAmount;
  final String notes;
  final AllergenCode? allergenCode;

  const Ingredient({
    required this.name,
    required this.ucumUnit,
    required this.ucumAmount,
    required this.metricUnit,
    required this.metricAmount,
    required this.notes,
    this.allergenCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ucum_unit': ucumUnit.name,
      'ucum_amount': ucumAmount,
      'metric_unit': metricUnit.name,
      'metric_amount': metricAmount,
      'notes': notes,
      if (allergenCode != null) 'allergen_code': allergenCode!.name,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      ucumUnit: UcumUnit.values.firstWhere(
        (e) => e.name == json['ucum_unit'],
        orElse: () => UcumUnit.cup_us,
      ),
      ucumAmount: (json['ucum_amount'] ?? 0).toDouble(),
      metricUnit: MetricUnit.values.firstWhere(
        (e) => e.name == json['metric_unit'],
        orElse: () => MetricUnit.g,
      ),
      metricAmount: (json['metric_amount'] ?? 0).toDouble(),
      notes: json['notes'] ?? '',
      allergenCode: json['allergen_code'] != null
          ? AllergenCode.values.firstWhere(
              (e) => e.name == json['allergen_code'],
              orElse: () => AllergenCode.GLUTEN,
            )
          : null,
    );
  }
}