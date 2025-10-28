import 'package:flutter/material.dart';
import '../../utils/card_dimensions.dart';

/// Responsive “Add Meal” card sized via [CardDimensions].
class AddMealCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddMealCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Align dimensions with MealCard (specs/LANDSCAPE_ORIENTATION.md).
    final rowHeight = CardDimensions.rowHeightFor(context);
    final cardWidth = CardDimensions.cardWidthFor(context: context, rowHeight: rowHeight);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 32,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
