import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Display a single day cell in the calendar grid
class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final int mealCount;
  final double? totalTime;
  final bool isToday;
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.mealCount,
    this.totalTime,
    required this.isToday,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayOfMonth = DateFormat('d').format(date);
    final dayOfWeek = DateFormat('EEE').format(date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: mealCount > 0
              ? theme.colorScheme.primaryContainer.withAlpha(51)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isToday
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isToday ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayOfWeek,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayOfMonth,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isToday
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (mealCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$mealCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
            if (totalTime != null && totalTime! > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatTime(totalTime!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(double minutes) {
    final hours = minutes ~/ 60;
    final mins = (minutes % 60).toInt();
    if (hours > 0) {
      return '${hours}h${mins}m';
    }
    return '${mins}m';
  }
}
