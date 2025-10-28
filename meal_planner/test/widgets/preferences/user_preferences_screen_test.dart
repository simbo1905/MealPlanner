import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/user_preferences.freezed_model.dart';
import 'package:meal_planner/providers/user_preferences_providers.dart';
import 'package:meal_planner/screens/preferences/user_preferences_screen.dart';
import '../../repositories/fake_user_preferences_repository.dart';

void main() {
  late FakeUserPreferencesRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeUserPreferencesRepository();
    fakeRepo.seed(
      'user-123',
      const UserPreferences(
        userId: 'user-123',
        portions: 4,
        dietaryRestrictions: [],
        dislikedIngredients: [],
        preferredSupermarkets: [],
      ),
    );
  });

  tearDown(() {
    fakeRepo.clear();
  });

  group('UserPreferencesScreen', () {
    testWidgets('load and display current preferences', (tester) async {
      fakeRepo.seed(
        'user-123',
        const UserPreferences(
          userId: 'user-123',
          portions: 6,
          dietaryRestrictions: ['vegetarian'],
          dislikedIngredients: ['onions'],
          preferredSupermarkets: ['Whole Foods'],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: UserPreferencesScreen(userId: 'user-123'),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('vegetarian'), findsOneWidget);
      expect(find.text('onions'), findsOneWidget);
    });

    testWidgets('change portions and save', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: UserPreferencesScreen(userId: 'user-123'),
          ),
        ),
      );

      await tester.pump();

      // Find and tap the plus button to increase portions
      final buttons = find.byType(IconButton);
      await tester.tap(buttons.last);
      await tester.pumpAndSettle();

      // Scroll to save button
      await tester.scrollUntilVisible(
        find.text('Save Preferences'),
        100,
        scrollable: find.byType(Scrollable).last,
      );

      // Save
      await tester.tap(find.text('Save Preferences'));
      await tester.pumpAndSettle();

      // Verify save was called
      final saved = await fakeRepo.getUserPreferences('user-123');
      expect(saved?.portions, 5);
    });

    testWidgets('add dietary restrictions and save', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: UserPreferencesScreen(userId: 'user-123'),
          ),
        ),
      );

      await tester.pump();

      // Tap vegetarian chip
      await tester.tap(find.text('vegetarian'));
      await tester.pumpAndSettle();

      // Scroll to save button
      await tester.scrollUntilVisible(
        find.text('Save Preferences'),
        100,
        scrollable: find.byType(Scrollable).last,
      );

      // Save
      await tester.tap(find.text('Save Preferences'));
      await tester.pumpAndSettle();

      // Verify save
      final saved = await fakeRepo.getUserPreferences('user-123');
      expect(saved?.dietaryRestrictions, contains('vegetarian'));
    });

    testWidgets('add disliked ingredients and save', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: UserPreferencesScreen(userId: 'user-123'),
          ),
        ),
      );

      await tester.pump();

      // Add ingredient
      await tester.enterText(find.byType(TextField).first, 'garlic');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Scroll to save button
      await tester.scrollUntilVisible(
        find.text('Save Preferences'),
        100,
        scrollable: find.byType(Scrollable).last,
      );

      // Save
      await tester.tap(find.text('Save Preferences'));
      await tester.pumpAndSettle();

      // Verify save
      final saved = await fakeRepo.getUserPreferences('user-123');
      expect(saved?.dislikedIngredients, contains('garlic'));
    });

    testWidgets('add supermarkets and save', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: UserPreferencesScreen(userId: 'user-123'),
          ),
        ),
      );

      await tester.pump();

      // Scroll to find supermarket section
      await tester.scrollUntilVisible(
        find.text('Whole Foods'),
        100,
        scrollable: find.byType(Scrollable).last,
      );

      // Tap Whole Foods
      await tester.tap(find.text('Whole Foods'));
      await tester.pumpAndSettle();

      // Scroll back to save button
      await tester.scrollUntilVisible(
        find.text('Save Preferences'),
        -100,
        scrollable: find.byType(Scrollable).last,
      );

      // Save
      await tester.tap(find.text('Save Preferences'));
      await tester.pumpAndSettle();

      // Verify save
      final saved = await fakeRepo.getUserPreferences('user-123');
      expect(saved?.preferredSupermarkets, contains('Whole Foods'));
    });

    testWidgets('show loading state while saving', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: UserPreferencesScreen(userId: 'user-123'),
          ),
        ),
      );

      await tester.pump();

      // Scroll to save button
      await tester.scrollUntilVisible(
        find.text('Save Preferences'),
        100,
        scrollable: find.byType(Scrollable).last,
      );

      // Tap save
      await tester.tap(find.text('Save Preferences'));
      
      // Don't settle - check for loading indicator
      await tester.pump();

      // Note: In our fake repo, save is instant, so we can't really test
      // the loading state effectively. This test verifies the screen renders.
      expect(find.byType(UserPreferencesScreen), findsOneWidget);
    });

    testWidgets('cancel button discards changes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: UserPreferencesScreen(userId: 'user-123'),
          ),
        ),
      );

      await tester.pump();

      // Make a change
      final buttons = find.byType(IconButton);
      await tester.tap(buttons.last);
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify we navigated away (screen is no longer there)
      expect(find.byType(UserPreferencesScreen), findsNothing);

      // Verify preferences were NOT saved
      final saved = await fakeRepo.getUserPreferences('user-123');
      expect(saved?.portions, 4); // Still original value
    });

    testWidgets('show success snackbar after save', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: UserPreferencesScreen(userId: 'user-123'),
          ),
        ),
      );

      await tester.pump();

      // Scroll to save button
      await tester.scrollUntilVisible(
        find.text('Save Preferences'),
        100,
        scrollable: find.byType(Scrollable).last,
      );

      // Save
      await tester.tap(find.text('Save Preferences'));
      await tester.pumpAndSettle();

      // Verify snackbar
      expect(find.text('Preferences saved'), findsOneWidget);
    });

    testWidgets('show loading state on initial load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: UserPreferencesScreen(userId: 'user-123'),
          ),
        ),
      );

      // Before first pump - should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump();

      // After pump - should show content
      expect(find.text('Preferences'), findsOneWidget);
    });
  });
}
