import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meal_planner/firebase_options.dart';

void main() {
  // Ensure integration_test binding is initialized for widget-style e2e runs.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Recipe Count Validation Tests', () {
    const expectedRecipeCount = 13496;

    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    test('Production recipes_v1 collection contains expected number of recipes',
        () async {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('recipes_v1')
          .count()
          .get();

      final actualCount = snapshot.count ?? 0;

      expect(
        actualCount,
        equals(expectedRecipeCount),
        reason: 'Recipe count mismatch in production database',
      );
    });

    test('Recipe documents contain required fields', () async {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('recipes_v1')
          .limit(10)
          .get();

      expect(snapshot.docs, isNotEmpty);

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Check required fields
        expect(data['id'], isNotNull, reason: 'Document missing id field');
        expect(data['title'], isNotNull, reason: 'Document missing title field');
        expect(data['titleLower'], isNotNull, reason: 'Document missing titleLower field');
        expect(data['titleTokens'], isNotNull, reason: 'Document missing titleTokens field');
        expect(data['ingredientNamesNormalized'], isNotNull,
            reason: 'Document missing ingredientNamesNormalized field');
        expect(data['createdAt'], isNotNull, reason: 'Document missing createdAt field');
      }
    });

    test('Title search query performs efficiently', () async {
      final firestore = FirebaseFirestore.instance;
      final startTime = DateTime.now();

      final snapshot = await firestore
          .collection('recipes_v1')
          .where('titleLower', isGreaterThanOrEqualTo: 'chicken')
          .where('titleLower', isLessThan: 'chicken~')
          .limit(10)
          .get();

      final duration = DateTime.now().difference(startTime);
      expect(snapshot.docs, isNotNull);

      expect(
        duration.inMilliseconds,
        lessThan(1000),
        reason: 'Title search took longer than 1 second',
      );
    });

    test('Ingredient search query performs efficiently', () async {
      final firestore = FirebaseFirestore.instance;
      final startTime = DateTime.now();

      final snapshot = await firestore
          .collection('recipes_v1')
          .where('ingredientNamesNormalized', arrayContains: 'chicken')
          .limit(10)
          .get();

      final duration = DateTime.now().difference(startTime);
      expect(snapshot.docs, isNotNull);

      expect(
        duration.inMilliseconds,
        lessThan(1000),
        reason: 'Ingredient search took longer than 1 second',
      );
    });

    test('Firestore indexes are properly configured', () async {
      final firestore = FirebaseFirestore.instance;
      
      // Test composite index 1: titleLower + createdAt
      try {
        final snapshot1 = await firestore
            .collection('recipes_v1')
            .where('titleLower', isGreaterThanOrEqualTo: 'a')
            .where('titleLower', isLessThan: 'b')
            .orderBy('titleLower')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        expect(snapshot1.docs, isNotEmpty, reason: 'titleLower index not working');
      } catch (e) {
        fail('Title index query failed: $e. Composite index may not be deployed.');
      }

      // Test composite index 2: ingredientNamesNormalized + createdAt
      try {
        await firestore
            .collection('recipes_v1')
            .where('ingredientNamesNormalized', arrayContains: 'chicken')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();
        // arrayContains doesn't require ordering in the index, but having it doesn't hurt
      } catch (e) {
        fail('Ingredient index query failed: $e. Composite index may not be deployed.');
      }
    });

    test('Sample recipes are accessible', () async {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('recipes_v1')
          .limit(5)
          .get();

      expect(snapshot.docs, isNotEmpty);
      
      for (var doc in snapshot.docs) {
        final title = doc['title'] as String?;
        expect(title, isNotNull);
        expect(title?.isNotEmpty, isTrue);
      }
    });
  });
}
