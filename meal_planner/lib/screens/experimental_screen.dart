import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/recipe.dart';
import '../services/pocketbase_service.dart';
import 'recipe_detail_screen.dart';

class ExperimentalScreen extends StatefulWidget {
  const ExperimentalScreen({Key? key}) : super(key: key);

  @override
  State<ExperimentalScreen> createState() => _ExperimentalScreenState();
}

class _ExperimentalScreenState extends State<ExperimentalScreen> {
  final PocketBaseService _pb = PocketBaseService();
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  bool _isOffline = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _pb.initialize();
      await _loadRecipes();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to PocketBase: $e';
        _isOffline = true;
      });

      try {
        await _loadRecipes();
      } catch (cacheError) {
        setState(() {
          _errorMessage = 'Failed to load from cache: $cacheError';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes = await _pb.getAllRecipes();
      setState(() {
        _recipes = recipes;
        _isOffline = !_pb.isOnline;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load recipes: $e';
        _isOffline = true;
      });
      rethrow;
    }
  }

  Future<void> _refreshRecipes() async {
    await _loadRecipes();
  }

  Future<void> _deleteRecipe(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: Key('confirm-delete-$id'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _pb.softDeleteRecipe(id);
        await _loadRecipes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  void _navigateToAddRecipe() async {
    final result = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(
        builder: (context) => const RecipeDetailScreen(),
      ),
    );

    if (result != null) {
      await _loadRecipes();
    }
  }

  void _navigateToEditRecipe(Recipe recipe) async {
    final result = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );

    if (result != null) {
      await _loadRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experiments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshRecipes,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isOffline)
            Container(
              key: const Key('offline-banner'),
              width: double.infinity,
              color: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: const [
                  Icon(Icons.cloud_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Offline - showing cached data',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          if (_errorMessage.isNotEmpty && !_isOffline)
            Container(
              width: double.infinity,
              color: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-recipe-fab'),
        onPressed: _isLoading ? null : _navigateToAddRecipe,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Lottie.asset('assets/lottie/sparkle.json'),
            ),
            const SizedBox(height: 16),
            const Text('Loading recipes...'),
          ],
        ),
      );
    }

    if (_recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No recipes yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first recipe',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshRecipes,
      child: ListView.builder(
        key: const Key('recipe-list'),
        itemCount: _recipes.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          return _buildRecipeCard(recipe);
        },
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      key: Key('recipe-item-${recipe.uuid}'),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Dismissible(
        key: Key('dismissible-${recipe.uuid}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Recipe'),
              content: Text('Delete "${recipe.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  key: Key('delete-recipe-${recipe.uuid}'),
                  onPressed: () => Navigator.pop(context, true),
                  child:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) async {
          await _pb.softDeleteRecipe(recipe.uuid!);
          setState(() {
            _recipes.removeWhere((r) => r.uuid == recipe.uuid);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${recipe.title} deleted')),
          );
        },
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.restaurant, color: Colors.blue.shade700),
          ),
          title: Text(
            recipe.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe.description.isNotEmpty)
                Text(
                  recipe.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.totalTime.toInt()} min',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.list_alt, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.ingredients.length} ingredients',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateToEditRecipe(recipe),
        ),
      ),
    );
  }
}
