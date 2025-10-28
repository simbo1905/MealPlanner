import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/models/user_preferences.freezed_model.dart';
import 'package:meal_planner/providers/user_preferences_providers.dart';
import 'package:meal_planner/widgets/preferences/portions_selector.dart';
import 'package:meal_planner/widgets/preferences/dietary_restrictions_selector.dart';
import 'package:meal_planner/widgets/preferences/disliked_ingredients_input.dart';
import 'package:meal_planner/widgets/preferences/preferred_supermarkets_selector.dart';

/// Screen for editing user preferences
class UserPreferencesScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserPreferencesScreen({
    required this.userId,
    super.key,
  });

  @override
  ConsumerState<UserPreferencesScreen> createState() =>
      _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends ConsumerState<UserPreferencesScreen> {
  late int _portions;
  late List<String> _dietaryRestrictions;
  late List<String> _dislikedIngredients;
  late List<String> _preferredSupermarkets;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(userPreferencesProvider(widget.userId));
    final notifierAsync =
        ref.watch(userPreferencesNotifierProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: prefsAsync.when(
        data: (prefs) {
          // Initialize form state from loaded preferences (once)
          if (!_isInitialized) {
            _portions = prefs.portions;
            _dietaryRestrictions = List.from(prefs.dietaryRestrictions);
            _dislikedIngredients = List.from(prefs.dislikedIngredients);
            _preferredSupermarkets = List.from(prefs.preferredSupermarkets);
            _isInitialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PortionsSelector(
                  currentPortions: _portions,
                  onChanged: (value) {
                    setState(() {
                      _portions = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                DietaryRestrictionsSelector(
                  selectedRestrictions: _dietaryRestrictions,
                  onChanged: (value) {
                    setState(() {
                      _dietaryRestrictions = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                DislikedIngredientsInput(
                  dislikedIngredients: _dislikedIngredients,
                  onChanged: (value) {
                    setState(() {
                      _dislikedIngredients = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                PreferredSupermarketsSelector(
                  selectedSupermarkets: _preferredSupermarkets,
                  onChanged: (value) {
                    setState(() {
                      _preferredSupermarkets = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: notifierAsync.isLoading
                      ? null
                      : () => _savePreferences(prefs),
                  child: notifierAsync.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Preferences'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading preferences: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userPreferencesProvider(widget.userId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePreferences(UserPreferences originalPrefs) async {
    final updatedPrefs = UserPreferences(
      userId: widget.userId,
      portions: _portions,
      dietaryRestrictions: _dietaryRestrictions,
      dislikedIngredients: _dislikedIngredients,
      preferredSupermarkets: _preferredSupermarkets,
    );

    try {
      await ref
          .read(userPreferencesNotifierProvider(widget.userId).notifier)
          .save(updatedPrefs);

      // Invalidate to reload fresh data
      ref.invalidate(userPreferencesProvider(widget.userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      }
    }
  }
}
