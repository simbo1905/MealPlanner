import 'package:flutter/foundation.dart';
import 'enums.dart';
import 'ingredient.dart';

@immutable
class Recipe {
  final String? uuid;
  final String title;
  final String imageUrl;
  final String description;
  final String notes;
  final List<String> preReqs;
  final double totalTime;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final MealType? mealType;

  const Recipe({
    this.uuid,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.notes,
    required this.preReqs,
    required this.totalTime,
    required this.ingredients,
    required this.steps,
    this.mealType,
  });
}