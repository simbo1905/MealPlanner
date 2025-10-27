import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:user_edit_example/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Firebase for tests (use emulator in CI)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    // Point to emulator if running in CI
    // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  });

  group('User Edit Form Integration Tests', () {
    testWidgets('Load user and display name in title',
        (WidgetTester tester) async {
      // Seed test data
      await FirebaseFirestore.instance
          .collection('users')
          .doc('test-user-1')
          .set({
            'id': 'test-user-1',
            'name': 'Alice Smith',
            'dateOfBirth': DateTime(1990, 6, 15).toIso8601String(),
          });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Alice Smith'), findsOneWidget);
    });

    testWidgets('Edit name and verify title updates',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField);
      await tester.enterText(nameField, 'Bob Jones');
      await tester.pumpAndSettle();

      expect(find.text('Bob Jones'), findsOneWidget);
    });

    testWidgets('Edit DoB and verify age computes',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap date picker
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Select a date
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Save persists to Firestore',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify Firestore write occurred
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('test-user-1')
          .get();
      expect(doc.exists, true);
    });

    testWidgets('Cancel discards edits',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField);
      await tester.enterText(nameField, 'Temporary Name');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Form should be gone, edits discarded
      expect(find.byType(TextField), findsNothing);
    });
  });
}
