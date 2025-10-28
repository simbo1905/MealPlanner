import 'dart:async';
import 'package:meal_planner/models/meal_assignment.freezed_model.dart';
import 'package:meal_planner/repositories/meal_assignment_repository.dart';

/// In-memory fake repository for meal assignments used in widget tests.
class FakeMealAssignmentRepository implements MealAssignmentRepository {
  final Map<String, MealAssignment> _assignments = {};
  final Map<String, StreamController<List<MealAssignment>>> _controllers = {};

  /// Pre-seed a meal assignment for testing
  void seed(String assignmentId, MealAssignment assignment) {
    _assignments[assignmentId] = assignment;
    _notifyListeners(assignment.dayIsoDate);
  }

  /// Clear all assignments
  void clear() {
    _assignments.clear();
    for (var controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  /// Watch assignments for a specific day
  Stream<List<MealAssignment>> watchAssignmentsForDay(String isoDate) {
    _controllers[isoDate] ??= StreamController<List<MealAssignment>>.broadcast();
    Future.microtask(() {
      if (!_controllers[isoDate]!.isClosed) {
        final dayAssignments = _assignments.values
            .where((a) => a.dayIsoDate == isoDate)
            .toList();
        _controllers[isoDate]!.add(dayAssignments);
      }
    });
    return _controllers[isoDate]!.stream;
  }

  /// Watch assignments for a week
  Stream<Map<String, List<MealAssignment>>> watchWeekAssignments(
      String startIsoDate) {
    final key = 'week_$startIsoDate';
    _controllers[key] ??= StreamController<List<MealAssignment>>.broadcast();
    
    Future.microtask(() {
      if (!_controllers[key]!.isClosed) {
        final startDate = DateTime.parse(startIsoDate);
        final endDate = startDate.add(const Duration(days: 7));
        
        final weekAssignments = _assignments.values.where((a) {
          final assignmentDate = DateTime.parse(a.dayIsoDate);
          return assignmentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                 assignmentDate.isBefore(endDate);
        }).toList();
        
        _controllers[key]!.add(weekAssignments);
      }
    });
    
    // Convert to map format
    return _controllers[key]!.stream.map((assignments) {
      final Map<String, List<MealAssignment>> grouped = {};
      for (var assignment in assignments) {
        grouped.putIfAbsent(assignment.dayIsoDate, () => []);
        grouped[assignment.dayIsoDate]!.add(assignment);
      }
      return grouped;
    });
  }

  /// Assign a meal
  Future<String> assign(MealAssignment assignment) async {
    _assignments[assignment.id] = assignment;
    _notifyListeners(assignment.dayIsoDate);
    return assignment.id;
  }

  /// Unassign a meal
  Future<void> unassign(String assignmentId) async {
    final assignment = _assignments.remove(assignmentId);
    if (assignment != null) {
      _notifyListeners(assignment.dayIsoDate);
    }
  }

  /// Get assignment by ID
  Future<MealAssignment?> getAssignment(String assignmentId) async {
    return _assignments[assignmentId];
  }

  /// Get all assignments (for testing)
  @override
  List<MealAssignment> getAllAssignments() {
    return _assignments.values.toList();
  }

  /// Get assignments within a date range
  @override
  Future<List<MealAssignment>> getMealAssignments(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _assignments.values
        .where((a) {
          final assignmentDate = DateTime.parse(a.dayIsoDate);
          return assignmentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                 assignmentDate.isBefore(endDate);
        })
        .toList();
  }

  void _notifyListeners(String isoDate) {
    if (_controllers.containsKey(isoDate) && !_controllers[isoDate]!.isClosed) {
      final dayAssignments = _assignments.values
          .where((a) => a.dayIsoDate == isoDate)
          .toList();
      _controllers[isoDate]!.add(dayAssignments);
    }
  }
}
