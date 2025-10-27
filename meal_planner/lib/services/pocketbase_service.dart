import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/enums.dart';
import '../models/store_event.dart';
import '../models/entity_snapshot.dart';
import 'recipe_cache.dart';

class PocketBaseService {
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;

  late final PocketBase pb;
  final RecipeCache _cache = RecipeCache();
  bool _isInitialized = false;
  bool _isOnline = true;

  PocketBaseService._internal() {
    pb = PocketBase('http://127.0.0.1:8091');
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final authData = await pb.admins.authWithPassword(
        'dev@MealPlanner.local',
        'dev123456',
      );

      if (authData.token.isNotEmpty) {
        _isInitialized = true;
        _isOnline = true;
      }
    } catch (e) {
      _isOnline = false;
      rethrow;
    }
  }

  Future<bool> healthCheck() async {
    try {
      final response = await pb.health.check();
      _isOnline = response.code == 200;
      return _isOnline;
    } catch (e) {
      _isOnline = false;
      return false;
    }
  }

  bool get isOnline => _isOnline;

  Future<List<Recipe>> getAllRecipes() async {
    try {
      final records = await pb.collection('recipes_v1').getFullList(
            filter: 'is_deleted = false',
            sort: 'title',
          );

      final recipes = records.map((record) => _recordToRecipe(record)).toList();

      await _cache.saveRecipes(recipes);
      _isOnline = true;

      return recipes;
    } catch (e) {
      _isOnline = false;

      final cachedRecipes = await _cache.loadRecipes();
      return cachedRecipes;
    }
  }

  Future<Recipe?> getRecipe(String id) async {
    try {
      final record = await pb.collection('recipes_v1').getOne(id);
      _isOnline = true;
      return _recordToRecipe(record);
    } catch (e) {
      _isOnline = false;

      final cachedRecipes = await _cache.loadRecipes();
      try {
        return cachedRecipes.firstWhere((r) => r.uuid == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<Recipe> createRecipe(Recipe recipe) async {
    final data = _recipeToData(recipe);

    try {
      final record = await pb.collection('recipes_v1').create(body: data);
      _isOnline = true;

      final created = _recordToRecipe(record);
      await _cache.addOrUpdateRecipe(created);

      return created;
    } catch (e) {
      _isOnline = false;
      rethrow;
    }
  }

  Future<Recipe> updateRecipe(String id, Recipe recipe) async {
    final data = _recipeToData(recipe);

    try {
      final record = await pb.collection('recipes_v1').update(id, body: data);
      _isOnline = true;

      final updated = _recordToRecipe(record);
      await _cache.addOrUpdateRecipe(updated);

      return updated;
    } catch (e) {
      _isOnline = false;
      rethrow;
    }
  }

  Future<void> softDeleteRecipe(String id) async {
    try {
      await pb.collection('recipes_v1').update(id, body: {'is_deleted': true});
      _isOnline = true;

      await _cache.removeRecipe(id);
    } catch (e) {
      _isOnline = false;
      rethrow;
    }
  }

  Recipe _recordToRecipe(RecordModel record) {
    final json = record.data['recipe_json'] as Map<String, dynamic>? ?? {};

    return Recipe(
      uuid: record.id,
      title: record.data['title'] ?? '',
      description: record.data['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      notes: json['notes'] ?? '',
      preReqs: (json['pre_reqs'] as List?)?.cast<String>() ?? [],
      totalTime: (record.data['total_time'] ?? 0).toDouble(),
      ingredients: (json['ingredients'] as List?)
              ?.map((i) => Ingredient.fromJson(i))
              .toList() ??
          [],
      steps: (json['steps'] as List?)?.cast<String>() ?? [],
      mealType: null,
    );
  }

  Map<String, dynamic> _recipeToData(Recipe recipe) {
    final recipeJson = {
      'image_url': recipe.imageUrl,
      'notes': recipe.notes,
      'pre_reqs': recipe.preReqs,
      'ingredients': recipe.ingredients.map((i) => i.toJson()).toList(),
      'steps': recipe.steps,
    };

    return {
      'title': recipe.title,
      'description': recipe.description,
      'total_time': recipe.totalTime.toInt(),
      'status': 'Complete',
      'is_deleted': false,
      'recipe_json': recipeJson,
    };
  }

  /// Create a single event in the edits collection.
  Future<void> createEvent(StoreEvent event) async {
    try {
      // toJson() includes 'event_id' field with the app UUID
      await pb.collection('edits').create(body: event.toJson());
      _isOnline = true;
    } catch (e) {
      _isOnline = false;
      rethrow;
    }
  }

  /// Get all events for a given entity ID.
  Future<List<StoreEvent>> getEvents(String entityId) async {
    try {
      final records = await pb.collection('edits').getFullList(
            filter: 'entity_id = "$entityId"',
            sort: 'next_version',
          );

      final events = records
          .map((record) =>
              StoreEvent.fromJson(record.id, record.data as Map<String, dynamic>))
          .toList();

      _isOnline = true;
      return events;
    } catch (e) {
      _isOnline = false;
      return [];
    }
  }

  /// Get the current snapshot for an entity.
  Future<EntitySnapshot?> getSnapshot(String entityId) async {
    try {
      final record = await pb.collection('snapshots').getOne(entityId);
      _isOnline = true;
      return EntitySnapshot.fromJson(record.id, record.data as Map<String, dynamic>);
    } catch (e) {
      _isOnline = false;
      return null;
    }
  }

  /// Create or update a snapshot for an entity.
  Future<void> upsertSnapshot(EntitySnapshot snapshot) async {
    try {
      try {
        await pb.collection('snapshots').update(
              snapshot.id,
              body: snapshot.toJson(),
            );
      } catch (_) {
        // If update fails, try create with id
        final body = snapshot.toJson();
        body['id'] = snapshot.id;  // PocketBase allows setting id on create
        await pb.collection('snapshots').create(body: body);
      }
      _isOnline = true;
    } catch (e) {
      _isOnline = false;
      rethrow;
    }
  }

  /// Batch create events (for efficient flush operations).
  /// Posts events in groups of 100 to PocketBase.
  Future<void> batchCreateEvents(List<StoreEvent> events) async {
    if (events.isEmpty) return;

    try {
      for (final event in events) {
        await pb.collection('edits').create(body: event.toJson());
      }
      _isOnline = true;
    } catch (e) {
      _isOnline = false;
      rethrow;
    }
  }

  Future<void> seedTestData() async {
    try {
      final existingRecipes = await getAllRecipes();
      if (existingRecipes.isNotEmpty) {
        return;
      }

      final testRecipes = _getTestRecipes();

      for (final recipe in testRecipes) {
        await createRecipe(recipe);
      }
    } catch (e) {
      rethrow;
    }
  }

  List<Recipe> _getTestRecipes() {
    return [
      Recipe(
        title: 'Chicken Stir-Fry',
        description: 'Quick and healthy chicken stir-fry with vegetables',
        imageUrl: '',
        notes: 'Use high heat for best results',
        preReqs: [],
        totalTime: 30,
        ingredients: [
          const Ingredient(
            name: 'Chicken breast',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 2.0,
            metricUnit: MetricUnit.g,
            metricAmount: 500,
            notes: 'Cut into strips',
          ),
          const Ingredient(
            name: 'Mixed vegetables',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 1.5,
            metricUnit: MetricUnit.g,
            metricAmount: 300,
            notes: 'Bell peppers, broccoli, carrots',
          ),
        ],
        steps: [
          'Heat oil in wok over high heat',
          'Cook chicken until golden',
          'Add vegetables and stir-fry',
          'Season and serve',
        ],
      ),
      Recipe(
        title: 'Roast Chicken',
        description: 'Classic roast chicken with herbs',
        imageUrl: '',
        notes: 'Let rest before carving',
        preReqs: [],
        totalTime: 90,
        ingredients: [
          const Ingredient(
            name: 'Whole chicken',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 6.0,
            metricUnit: MetricUnit.g,
            metricAmount: 1500,
            notes: '',
          ),
        ],
        steps: [
          'Preheat oven to 180°C',
          'Season chicken generously',
          'Roast for 75 minutes',
          'Rest for 10 minutes',
        ],
      ),
      Recipe(
        title: 'Spaghetti Bolognese',
        description: 'Traditional Italian meat sauce with pasta',
        imageUrl: '',
        notes: 'Simmer for rich flavor',
        preReqs: [],
        totalTime: 45,
        ingredients: [
          const Ingredient(
            name: 'Spaghetti',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 4.0,
            metricUnit: MetricUnit.g,
            metricAmount: 400,
            notes: '',
          ),
          const Ingredient(
            name: 'Ground beef',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 2.0,
            metricUnit: MetricUnit.g,
            metricAmount: 500,
            notes: '',
          ),
        ],
        steps: [
          'Cook pasta according to package',
          'Brown beef in large pan',
          'Add tomato sauce and simmer',
          'Serve over pasta',
        ],
      ),
      Recipe(
        title: 'Vegetable Curry',
        description: 'Aromatic vegetable curry with coconut milk',
        imageUrl: '',
        notes: 'Adjust spice level to taste',
        preReqs: [],
        totalTime: 40,
        ingredients: [
          const Ingredient(
            name: 'Mixed vegetables',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 3.0,
            metricUnit: MetricUnit.g,
            metricAmount: 600,
            notes: 'Potato, cauliflower, peas',
          ),
          const Ingredient(
            name: 'Coconut milk',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 1.5,
            metricUnit: MetricUnit.ml,
            metricAmount: 400,
            notes: '',
          ),
        ],
        steps: [
          'Sauté curry paste in oil',
          'Add vegetables and cook',
          'Pour in coconut milk',
          'Simmer until tender',
        ],
      ),
      Recipe(
        title: 'Fish and Chips',
        description: 'Crispy battered fish with thick-cut chips',
        imageUrl: '',
        notes: 'Serve with tartar sauce',
        preReqs: [],
        totalTime: 35,
        ingredients: [
          const Ingredient(
            name: 'White fish fillets',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 2.5,
            metricUnit: MetricUnit.g,
            metricAmount: 600,
            notes: 'Cod or haddock',
          ),
          const Ingredient(
            name: 'Potatoes',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 4.0,
            metricUnit: MetricUnit.g,
            metricAmount: 800,
            notes: 'Cut into chips',
          ),
        ],
        steps: [
          'Heat oil for deep frying',
          'Prepare batter and coat fish',
          'Fry chips until golden',
          'Fry fish until crispy',
        ],
      ),
    ];
  }
}
