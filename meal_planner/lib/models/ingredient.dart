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
}