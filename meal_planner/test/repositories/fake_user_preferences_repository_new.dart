import 'package:meal_planner/models/user_preferences.freezed_model.dart';
import 'package:meal_planner/providers/user_preferences_providers.dart';

/// In-memory fake repository for testing UserPreferences
/// Implements UserPreferencesRepository interface
class FakeUserPreferencesRepository implements UserPreferencesRepository {
  final Map<String, UserPreferences> _prefs = {};

  /// Seed test data for a specific user
  void seed(String userId, UserPreferences prefs) {
    _prefs[userId] = prefs;
  }

  /// Clear all test data
  void clear() {
    _prefs.clear();
  }

  @override
  Future<UserPreferences?> getUserPreferences(String userId) async {
    return _prefs[userId];
  }

  @override
  Future<void> save(UserPreferences prefs) async {
    _prefs[prefs.userId] = prefs;
  }

  /// Update portions only
  Future<void> updatePortions(String userId, int portions) async {
    final current = _prefs[userId];
    if (current != null) {
      _prefs[userId] = current.copyWith(portions: portions);
    }
  }

  /// Add dietary restriction
  Future<void> addDietaryRestriction(String userId, String restriction) async {
    final current = _prefs[userId];
    if (current != null) {
      final updated = [...current.dietaryRestrictions];
      if (!updated.contains(restriction)) {
        updated.add(restriction);
      }
      _prefs[userId] = current.copyWith(dietaryRestrictions: updated);
    }
  }

  /// Remove dietary restriction
  Future<void> removeDietaryRestriction(String userId, String restriction) async {
    final current = _prefs[userId];
    if (current != null) {
      final updated = [...current.dietaryRestrictions];
      updated.remove(restriction);
      _prefs[userId] = current.copyWith(dietaryRestrictions: updated);
    }
  }
}
