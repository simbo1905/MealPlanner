import 'package:flutter/material.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/models/enums.dart';

/// RecipeCard displays a recipe summary with image, title, time, and allergen badges.
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image or placeholder
            _buildImage(),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Cook time and ingredient count
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.totalTime.toInt()} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.shopping_basket, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.ingredients.length} ingredients',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  // Allergen badges
                  if (_getAllergens().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _getAllergens()
                          .map((allergen) => _buildAllergenBadge(allergen))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (recipe.imageUrl.isEmpty) {
      return Container(
        height: 150,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.restaurant,
            size: 64,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return Image.network(
      recipe.imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 150,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  List<AllergenCode> _getAllergens() {
    final allergens = <AllergenCode>{};
    for (var ingredient in recipe.ingredients) {
      if (ingredient.allergenCode != null) {
        allergens.add(ingredient.allergenCode!);
      }
    }
    return allergens.toList();
  }

  Widget _buildAllergenBadge(AllergenCode allergen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Text(
        allergen.name,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.orange,
        ),
      ),
    );
  }
}
