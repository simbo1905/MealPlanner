import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_planner/models/meal.freezed_model.dart';
import 'meal_repository.dart';

class FirestoreMealRepository extends MealRepository {
  FirestoreMealRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('meals');

  @override
  Stream<List<Meal>> watchMeals(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('date')
        .orderBy('slot')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              final date = (data['date'] as Timestamp).toDate();
              final createdAt = (data['createdAt'] as Timestamp).toDate();
              return Meal.fromJson({
                'id': doc.id,
                'recipeTitle': data['recipeTitle'],
                'date': date.toIso8601String(),
                'slot': data['slot'],
                'userId': data['userId'],
                'createdAt': createdAt.toIso8601String(),
              });
            }).toList());
  }

  @override
  Future<Meal> addMeal({
    required String userId,
    required DateTime date,
    required MealSlot slot,
    required String recipeTitle,
    MealConflictStrategy conflictStrategy = MealConflictStrategy.keepBoth,
  }) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final slotName = slot.name;
    final dateKey = _dateToKey(normalizedDate);

    final batch = _firestore.batch();

    if (conflictStrategy == MealConflictStrategy.replace) {
      final existing = await _collection
          .where('userId', isEqualTo: userId)
          .where('dateKey', isEqualTo: dateKey)
          .where('slot', isEqualTo: slotName)
          .get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }
    }

    final doc = _collection.doc();
    final now = DateTime.now();
    batch.set(doc, {
      'recipeTitle': recipeTitle,
      'date': normalizedDate,
      'dateKey': dateKey,
      'slot': slotName,
      'userId': userId,
      'createdAt': now,
    });

    await batch.commit();

    return Meal(
      id: doc.id,
      recipeTitle: recipeTitle,
      date: normalizedDate,
      slot: slot,
      userId: userId,
      createdAt: now,
    );
  }

  @override
  Future<void> deleteMeal({required String userId, required String mealId}) async {
    final doc = _collection.doc(mealId);
    final snapshot = await doc.get();
    if (!snapshot.exists) return;
    if (snapshot.data()?['userId'] != userId) return;
    await doc.delete();
  }

  @override
  Future<void> updateMeal({
    required String userId,
    required String mealId,
    DateTime? newDate,
    MealSlot? newSlot,
    String? newRecipeTitle,
  }) async {
    final doc = _collection.doc(mealId);
    final snapshot = await doc.get();
    if (!snapshot.exists) return;
    if (snapshot.data()?['userId'] != userId) return;

    final update = <String, dynamic>{};
    if (newDate != null) {
      final normalized = DateTime(newDate.year, newDate.month, newDate.day);
      update['date'] = normalized;
      update['dateKey'] = _dateToKey(normalized);
    }
    if (newSlot != null) {
      update['slot'] = newSlot.name;
    }
    if (newRecipeTitle != null) {
      update['recipeTitle'] = newRecipeTitle;
    }

    if (update.isEmpty) return;
    await doc.update(update);
  }

  @override
  Future<void> swapMeals({
    required String userId,
    required String firstMealId,
    required String secondMealId,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final firstRef = _collection.doc(firstMealId);
      final secondRef = _collection.doc(secondMealId);

      final firstSnap = await transaction.get(firstRef);
      final secondSnap = await transaction.get(secondRef);

      final firstData = firstSnap.data();
      final secondData = secondSnap.data();

      if (firstData == null || secondData == null) return;
      if (firstData['userId'] != userId || secondData['userId'] != userId) {
        return;
      }

      transaction.update(firstRef, {
        'date': secondData['date'],
        'dateKey': secondData['dateKey'],
        'slot': secondData['slot'],
      });

      transaction.update(secondRef, {
        'date': firstData['date'],
        'dateKey': firstData['dateKey'],
        'slot': firstData['slot'],
      });
    });
  }

  @override
  Future<Meal?> findMealByDateSlot({
    required String userId,
    required DateTime date,
    required MealSlot slot,
  }) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('dateKey', isEqualTo: _dateToKey(normalized))
        .where('slot', isEqualTo: slot.name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();
    final docDate = (data['date'] as Timestamp).toDate();
    final docCreatedAt = (data['createdAt'] as Timestamp).toDate();
    return Meal.fromJson({
      'id': doc.id,
      'recipeTitle': data['recipeTitle'],
      'date': docDate.toIso8601String(),
      'slot': data['slot'],
      'userId': data['userId'],
      'createdAt': docCreatedAt.toIso8601String(),
    });
  }

  String _dateToKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
