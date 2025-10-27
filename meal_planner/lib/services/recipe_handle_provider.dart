import '../models/recipe.dart';
import 'entity_handle.dart';
import 'local_buffer.dart';

/// Factory and example usage for Recipe EntityHandle.
/// 
/// Demonstrates how to integrate event-sourcing into existing entity types.
class RecipeHandleProvider {
  static EntityHandle<Recipe> createHandle(String entityId) {
    return EntityHandle<Recipe>(
      entityId: entityId,
      fromJson: _recipeFromJson,
      toJson: _recipeToJson,
    );
  }

  static Map<String, dynamic> _recipeToJson(Recipe recipe) {
    return {
      'uuid': recipe.uuid,
      'title': recipe.title,
      'imageUrl': recipe.imageUrl,
      'description': recipe.description,
      'notes': recipe.notes,
      'preReqs': recipe.preReqs,
      'totalTime': recipe.totalTime,
      'ingredients': recipe.ingredients
          .map((i) => {
                'name': i.name,
                'ucumUnit': i.ucumUnit.toString(),
                'ucumAmount': i.ucumAmount,
                'metricUnit': i.metricUnit.toString(),
                'metricAmount': i.metricAmount,
                'notes': i.notes,
              })
          .toList(),
      'steps': recipe.steps,
      'mealType': recipe.mealType?.toString(),
    };
  }

  static Recipe _recipeFromJson(Map<String, dynamic> json) {
    return Recipe(
      uuid: json['uuid'] as String?,
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      preReqs: (json['preReqs'] as List?)?.cast<String>() ?? [],
      totalTime: (json['totalTime'] as num?)?.toDouble() ?? 0,
      ingredients: (json['ingredients'] as List?)
              ?.map((i) => _ingredientFromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      steps: (json['steps'] as List?)?.cast<String>() ?? [],
      mealType: null,
    );
  }

  static Map<String, dynamic> _ingredientToJson(dynamic ingredient) {
    return {
      'name': ingredient.name,
      'ucumUnit': ingredient.ucumUnit.toString(),
      'ucumAmount': ingredient.ucumAmount,
      'metricUnit': ingredient.metricUnit.toString(),
      'metricAmount': ingredient.metricAmount,
      'notes': ingredient.notes,
    };
  }

  static dynamic _ingredientFromJson(Map<String, dynamic> json) {
    // This is a placeholder; in real code, you'd import Ingredient and construct it properly
    return json;
  }
}
