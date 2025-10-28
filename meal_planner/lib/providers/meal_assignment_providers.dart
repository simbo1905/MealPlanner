import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/meal_assignment.freezed_model.dart';

part 'meal_assignment_providers.g.dart';

// Stream of meal assignments for a specific day
@riverpod
Stream<List<MealAssignment>> mealAssignmentsForDay(
  Ref ref,
  String isoDate,
) {
  return FirebaseFirestore.instance
      .collection('meal_assignments')
      .where('dayIsoDate', isEqualTo: isoDate)
      .orderBy('assignedAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => MealAssignment.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  });
}

// Stream of meal assignments for a week (7 days starting from startIsoDate)
@riverpod
Stream<Map<String, List<MealAssignment>>> weekMealAssignments(
  Ref ref,
  String startIsoDate,
) {
  return FirebaseFirestore.instance
      .collection('meal_assignments')
      .where('dayIsoDate',
          isGreaterThanOrEqualTo: startIsoDate,
          isLessThan: _nextDay(startIsoDate, 7))
      .orderBy('dayIsoDate')
      .orderBy('assignedAt', descending: true)
      .snapshots()
      .map((snapshot) {
    final Map<String, List<MealAssignment>> result = {};
    for (var doc in snapshot.docs) {
      final assignment = MealAssignment.fromJson({...doc.data(), 'id': doc.id});
      result.putIfAbsent(assignment.dayIsoDate, () => []);
      result[assignment.dayIsoDate]!.add(assignment);
    }
    return result;
  });
}

// Notifier for assignment operations
@riverpod
class MealAssignmentNotifier extends _$MealAssignmentNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<String> assign(String recipeId, String dayIsoDate) async {
    String assignedId = '';
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final doc = FirebaseFirestore.instance.collection('meal_assignments').doc();
      final assignment = MealAssignment(
        id: doc.id,
        recipeId: recipeId,
        dayIsoDate: dayIsoDate,
        assignedAt: DateTime.now(),
      );
      await doc.set(assignment.toJson());
      assignedId = doc.id;
    });
    return assignedId;
  }

  Future<void> unassign(String assignmentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance
          .collection('meal_assignments')
          .doc(assignmentId)
          .delete();
    });
  }
}

String _nextDay(String isoDate, int daysAhead) {
  final date = DateTime.parse(isoDate);
  return date.add(Duration(days: daysAhead)).toIso8601String().split('T')[0];
}
