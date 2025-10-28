import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/workspace_recipe.freezed_model.dart';
import '../models/recipe.freezed_model.dart';
import '../models/ingredient.freezed_model.dart';
import '../models/enums.dart';

part 'ocr_provider.g.dart';

/// Mock OCR processing provider
/// In production, this would call MistralAI Vision API
@riverpod
Future<WorkspaceRecipe> processRecipeImage(
  Ref ref,
  String imagePath,
) async {
  // Simulate API delay
  await Future.delayed(const Duration(seconds: 2));

  // Generate Firebase auto-IDs
  final workspaceId = FirebaseFirestore.instance.collection('workspace_recipes').doc().id;
  final recipeId = FirebaseFirestore.instance.collection('recipes').doc().id;

  // Return mock workspace recipe
  final recipe = Recipe(
    id: recipeId,
    title: 'Mock Recipe from Image',
    imageUrl: imagePath,
    description: 'This is a mock recipe extracted from the image',
    notes: 'AI-generated recipe - please review and edit',
    preReqs: const ['Preheat oven to 350°F'],
    totalTime: 45.0,
    ingredients: const [
      Ingredient(
        name: 'Flour',
        ucumAmount: 2.0,
        ucumUnit: UcumUnit.cupUs,
        metricAmount: 240.0,
        metricUnit: MetricUnit.g,
        notes: 'All-purpose',
      ),
      Ingredient(
        name: 'Sugar',
        ucumAmount: 1.0,
        ucumUnit: UcumUnit.cupUs,
        metricAmount: 200.0,
        metricUnit: MetricUnit.g,
        notes: 'Granulated',
      ),
      Ingredient(
        name: 'Eggs',
        ucumAmount: 2.0,
        ucumUnit: UcumUnit.cupUs,
        metricAmount: 100.0,
        metricUnit: MetricUnit.g,
        notes: 'Large',
      ),
    ],
    steps: const [
      'Mix dry ingredients together',
      'Beat eggs in a separate bowl',
      'Combine wet and dry ingredients',
      'Bake for 30 minutes',
    ],
  );

  return WorkspaceRecipe(
    id: workspaceId,
    recipe: recipe,
    status: WorkspaceRecipeStatus.draft,
    missingFields: [],
    photoIds: [imagePath],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
