import '../../models/recipe.freezed_model.dart';
import '../recipes_v1_repository.dart';

class FakeRecipesV1Repository implements RecipesV1Repository {
  FakeRecipesV1Repository({List<Recipe>? seed}) {
    _recipes = seed ?? _defaultRecipes;
  }

  late final List<Recipe> _recipes;

  static final List<Recipe> _defaultRecipes = [
    _recipe(
      id: 'recipe_spaghetti_bolognese',
      title: 'Spaghetti Bolognese',
      ingredients: ['spaghetti', 'beef', 'tomato', 'garlic'],
    ),
    _recipe(
      id: 'recipe_chicken_tikka',
      title: 'Chicken Tikka Masala',
      ingredients: ['chicken', 'yogurt', 'garam masala'],
    ),
    _recipe(
      id: 'recipe_beef_tacos',
      title: 'Beef Tacos',
      ingredients: ['beef', 'tortilla', 'lettuce', 'tomato'],
    ),
    _recipe(
      id: 'recipe_beef_bourguignon',
      title: 'Beef Bourguignon',
      ingredients: ['beef', 'red wine', 'mushroom'],
    ),
    _recipe(
      id: 'recipe_veggie_stir_fry',
      title: 'Vegetable Stir Fry',
      ingredients: ['broccoli', 'carrot', 'soy sauce'],
    ),
    _recipe(
      id: 'recipe_pesto_pasta',
      title: 'Pesto Pasta',
      ingredients: ['pasta', 'basil', 'parmesan'],
    ),
    _recipe(
      id: 'recipe_shrimp_scampi',
      title: 'Shrimp Scampi',
      ingredients: ['shrimp', 'garlic', 'butter'],
    ),
    _recipe(
      id: 'recipe_margherita_pizza',
      title: 'Margherita Pizza',
      ingredients: ['dough', 'tomato', 'mozzarella'],
    ),
    _recipe(
      id: 'recipe_caesar_salad',
      title: 'Chicken Caesar Salad',
      ingredients: ['chicken', 'romaine', 'parmesan'],
    ),
    _recipe(
      id: 'recipe_chili',
      title: 'Three Bean Chili',
      ingredients: ['beans', 'tomato', 'chili powder'],
    ),
    _recipe(
      id: 'recipe_beef_ramen',
      title: 'Beef Ramen Bowl',
      ingredients: ['beef', 'ramen', 'miso'],
    ),
    _recipe(
      id: 'recipe_tofu_curry',
      title: 'Tofu Coconut Curry',
      ingredients: ['tofu', 'coconut milk', 'curry'],
    ),
  ];

  static Recipe _recipe({
    required String id,
    required String title,
    required List<String> ingredients,
  }) {
    final normalized = ingredients.map((e) => e.toLowerCase()).toList();
    return Recipe(
      id: id,
      title: title,
      titleLower: title.toLowerCase(),
      titleTokens: title.toLowerCase().split(RegExp(r'\s+')),
      ingredientNamesNormalized: normalized,
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 0,
      ingredients: [],
      steps: [],
    );
  }

  @override
  Stream<List<Recipe>> searchByTitlePrefix(String prefix, {int limit = 10}) {
    if (prefix.isEmpty) return Stream.value([]);
    final lower = prefix.toLowerCase();
    final results = _recipes
        .where((recipe) => recipe.titleLower?.startsWith(lower) ?? false)
        .take(limit)
        .toList();
    return Stream.value(results);
  }

  @override
  Stream<List<Recipe>> searchByIngredient(String ingredient, {int limit = 10}) {
    if (ingredient.isEmpty) return Stream.value([]);
    final lower = ingredient.toLowerCase();
    final results = _recipes
        .where((recipe) => recipe.ingredientNamesNormalized?.contains(lower) ?? false)
        .take(limit)
        .toList();
    return Stream.value(results);
  }

  @override
  Future<Recipe?> getById(String recipeId) async {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == recipeId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> getTotalCount() async => _recipes.length;
}