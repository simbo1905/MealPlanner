import 'package:flutter/material.dart';

/// Display weekly summary with total meals and cook time
class WeeklySummary extends StatelessWidget {
  final int totalMeals;
  final double totalCookTime;
  final Map<String, int> mealsPerDay;

  const WeeklySummary({
    super.key,
    required this.totalMeals,
    required this.totalCookTime,
    required this.mealsPerDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '$totalMeals meals planned',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(totalCookTime),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (mealsPerDay.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Breakdown',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...mealsPerDay.entries.map((entry) {
                final date = DateTime.parse(entry.key);
                final dayName = _getDayName(date.weekday);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dayName,
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${entry.value} meal${entry.value == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(double minutes) {
    final hours = minutes ~/ 60;
    final mins = (minutes % 60).toInt();
    if (hours > 0 && mins > 0) {
      return '$hours hours $mins minutes total';
    } else if (hours > 0) {
      return '$hours hours total';
    } else {
      return '$mins minutes total';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
