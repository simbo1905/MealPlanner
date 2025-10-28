import 'package:flutter/material.dart';

/// Widget that displays a summary of shopping list costs and progress.
/// Shows total estimated cost, item counts, and a progress bar.
class CostSummary extends StatelessWidget {
  final double? totalEstimatedCost;
  final int itemCount;
  final int checkedCount;
  final String currencySymbol;

  const CostSummary({
    super.key,
    required this.totalEstimatedCost,
    required this.itemCount,
    required this.checkedCount,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    final cost = totalEstimatedCost ?? 0.0;
    final progress = itemCount > 0 ? checkedCount / itemCount : 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '$currencySymbol${cost.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      '$checkedCount of $itemCount items',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
