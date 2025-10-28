import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/meal_template.freezed_model.dart';
import '../../providers/meal_providers.dart';

class AddMealBottomSheet extends ConsumerWidget {
  final DateTime date;

  const AddMealBottomSheet({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(mealTemplatesProvider);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Text(
              'Select a Meal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Template list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: templates.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final template = templates[index];
                return _TemplateCard(
                  template: template,
                  onAdd: () => _onAddMeal(context, ref, template),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAddMeal(
    BuildContext context,
    WidgetRef ref,
    MealTemplate template,
  ) async {
    final repository = ref.read(mealRepositoryProvider);
    
    try {
      await repository.addMeal(date, template.templateId);
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${template.title} added'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _TemplateCard extends StatelessWidget {
  final MealTemplate template;
  final VoidCallback onAdd;

  const _TemplateCard({
    required this.template,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(template.colorHex);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getIconData(template.iconName),
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        template.title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        '${template.prepTimeMinutes} min prep',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
      ),
      trailing: ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add'),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexString) {
    final hex = hexString.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.blue;
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'bowl':
        return Icons.soup_kitchen;
      case 'egg':
        return Icons.egg;
      case 'restaurant':
        return Icons.restaurant;
      case 'fish':
        return Icons.set_meal;
      case 'fast-food':
        return Icons.fastfood;
      case 'local-bar':
        return Icons.local_bar;
      case 'nutrition':
        return Icons.apple;
      case 'ice-cream':
        return Icons.icecream;
      case 'local-cafe':
        return Icons.local_cafe;
      case 'free-breakfast':
        return Icons.free_breakfast;
      default:
        return Icons.restaurant_menu;
    }
  }
}
