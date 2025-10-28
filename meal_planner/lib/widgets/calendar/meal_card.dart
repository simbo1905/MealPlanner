import 'package:flutter/material.dart';
import '../../models/meal.freezed_model.dart';
import '../../models/meal_template.freezed_model.dart';
import '../../utils/card_dimensions.dart';

/// Responsive meal card that sizes itself using [CardDimensions].
class MealCard extends StatelessWidget {
  final Meal meal;
  final MealTemplate template;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final Key? deleteKey;

  const MealCard({
    super.key,
    required this.meal,
    required this.template,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.deleteKey,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(template.colorHex);
    // Sizing derived from CardDimensions (see specs/LANDSCAPE_ORIENTATION.md).
    final rowHeight = CardDimensions.rowHeightFor(context);
    final cardWidth = CardDimensions.cardWidthFor(context: context, rowHeight: rowHeight);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Left gradient stripe
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color,
                      color.withAlpha((0.7 * 255).round()),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconData(template.iconName),
                        size: 20,
                        color: color,
                      ),
                      const Spacer(),
                      if (onDelete != null)
                        GestureDetector(
                          key: deleteKey,
                          onTap: onDelete,
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    template.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${template.prepTimeMinutes} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
