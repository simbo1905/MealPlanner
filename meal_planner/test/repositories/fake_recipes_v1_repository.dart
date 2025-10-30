import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/repositories/recipes_v1_repository.dart';

/// Fake implementation of RecipesV1Repository for testing
class FakeRecipesV1Repository implements RecipesV1Repository {
  static final List<Recipe> _recipes = [
    Recipe(
      id: 'recipe_1',
      title: 'Miso-Butter Roast Chicken With Acorn Squash Panzanella',
      titleLower: 'miso-butter roast chicken with acorn squash panzanella',
      titleTokens: ['miso', 'butter', 'roast', 'chicken', 'with', 'acorn', 'squash', 'panzanella'],
      ingredientNamesNormalized: ['chicken', 'butter', 'miso', 'salt', 'squash', 'sage', 'rosemary'],
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 0.0,
      ingredients: [],
      steps: [],
    ),
    Recipe(
      id: 'recipe_2',
      title: 'Crispy Salt and Pepper Potatoes',
      titleLower: 'crispy salt and pepper potatoes',
      titleTokens: ['crispy', 'salt', 'and', 'pepper', 'potatoes'],
      ingredientNamesNormalized: ['potatoes', 'salt', 'pepper', 'oil'],
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 0.0,
      ingredients: [],
      steps: [],
    ),
    Recipe(
      id: 'recipe_3',
      title: 'Thanksgiving Mac and Cheese',
      titleLower: 'thanksgiving mac and cheese',
      titleTokens: ['thanksgiving', 'mac', 'and', 'cheese'],
      ingredientNamesNormalized: ['cheese', 'pasta', 'butter', 'milk'],
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 0.0,
      ingredients: [],
      steps: [],
    ),
    Recipe(
      id: 'recipe_4',
      title: 'Chicken Salad with Tomato',
      titleLower: 'chicken salad with tomato',
      titleTokens: ['chicken', 'salad', 'with', 'tomato'],
      ingredientNamesNormalized: ['chicken', 'tomato', 'lettuce', 'mayo'],
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 0.0,
      ingredients: [],
      steps: [],
    ),
    Recipe(
      id: 'recipe_5',
      title: 'Chicken Parmesan',
      titleLower: 'chicken parmesan',
      titleTokens: ['chicken', 'parmesan'],
      ingredientNamesNormalized: ['chicken', 'parmesan', 'tomato', 'pasta'],
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 0.0,
      ingredients: [],
      steps: [],
    ),
    Recipe(
      id: 'recipe_6',
      title: 'Italian Sausage and Bread Stuffing',
      titleLower: 'italian sausage and bread stuffing',
      titleTokens: ['italian', 'sausage', 'and', 'bread', 'stuffing'],
      ingredientNamesNormalized: ['sausage', 'bread', 'celery', 'onion'],
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 0.0,
      ingredients: [],
      steps: [],
    ),
    Recipe(
      id: 'recipe_7',
      title: 'Tomato Basil Soup',
      titleLower: 'tomato basil soup',
      titleTokens: ['tomato', 'basil', 'soup'],
      ingredientNamesNormalized: ['tomato', 'basil', 'cream', 'broth'],
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 0.0,
      ingredients: [],
      steps: [],
    ),
    Recipe(
      id: 'recipe_8',
      title: 'Grilled Cheese Sandwich',
      titleLower: 'grilled cheese sandwich',
      titleTokens: ['grilled', 'cheese', 'sandwich'],
      ingredientNamesNormalized: ['cheese', 'bread', 'butter'],
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 0.0,
      ingredients: [],
      steps: [],
    ),
    Recipe(
      id: 'recipe_9',
      title: 'Caesar Salad Roast Chicken',
      titleLower: 'caesar salad roast chicken',
      titleTokens: ['caesar', 'salad', 'roast', 'chicken'],
      ingredientNamesNormalized: ['chicken', 'lettuce', 'parmesan', 'anchovy'],
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 0.0,
      ingredients: [],
      steps: [],
    ),
    Recipe(
      id: 'recipe_10',
      title: 'Vegetable Stir Fry',
      titleLower: 'vegetable stir fry',
      titleTokens: ['vegetable', 'stir', 'fry'],
      ingredientNamesNormalized: ['vegetables', 'oil', 'soy sauce', 'garlic'],
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 0.0,
      ingredients: [],
      steps: [],
    ),
  ];

  @override
  Stream<List<Recipe>> searchByTitlePrefix(String prefix, {int limit = 10}) {
    if (prefix.isEmpty) return Stream.value([]);

    final lower = prefix.toLowerCase();
    final results = _recipes
        .where((recipe) => recipe.titleLower!.startsWith(lower))
        .take(limit)
        .toList();

    return Stream.value(results);
  }

  @override
  Stream<List<Recipe>> searchByIngredient(String ingredient, {int limit = 10}) {
    if (ingredient.isEmpty) return Stream.value([]);

    final lower = ingredient.toLowerCase();
    final results = _recipes
        .where((recipe) =>
            recipe.ingredientNamesNormalized?.any((ing) => ing.contains(lower)) ??
            false)
        .take(limit)
        .toList();

    return Stream.value(results);
  }

  @override
  Future<Recipe?> getById(String recipeId) async {
    try {
      return _recipes.firstWhere((r) => r.id == recipeId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getTotalCount() async {
    return _recipes.length;
  }
}
