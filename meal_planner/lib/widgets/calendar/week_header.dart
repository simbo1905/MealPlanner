import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekHeader extends StatelessWidget {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int weekNumber;
  final int totalMeals;
  final int totalPrepTime;

  const WeekHeader({
    super.key,
    required this.weekStart,
    required this.weekEnd,
    required this.weekNumber,
    required this.totalMeals,
    required this.totalPrepTime,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM');
    final dateRange = '${dateFormat.format(weekStart)} – ${dateFormat.format(weekEnd)}';
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFFF6F7F9),
          child: Row(
            children: [
              // Date range
              Text(
                dateRange,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              
              // Week pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'WEEK $weekNumber',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Total prep time
              if (totalPrepTime > 0) ...[
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatPrepTime(totalPrepTime)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey[300],
        ),
      ],
    );
  }

  String _formatPrepTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}m';
  }
}
