import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_preferences.freezed_model.dart';

part 'user_preferences_providers.g.dart';

/// Repository interface for user preferences
abstract class UserPreferencesRepository {
  Future<UserPreferences?> getUserPreferences(String userId);
  Future<void> save(UserPreferences prefs);
}

/// Firebase implementation of UserPreferencesRepository
class FirebaseUserPreferencesRepository implements UserPreferencesRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserPreferencesRepository(this._firestore);

  @override
  Future<UserPreferences?> getUserPreferences(String userId) async {
    try {
      final doc =
          await _firestore.collection('user_preferences').doc(userId).get();
      if (doc.exists) {
        return UserPreferences.fromJson({...doc.data()!, 'userId': userId});
      }
      return UserPreferences(userId: userId);
    } catch (e) {
      return UserPreferences(userId: userId);
    }
  }

  @override
  Future<void> save(UserPreferences prefs) async {
    await _firestore
        .collection('user_preferences')
        .doc(prefs.userId)
        .set(prefs.toJson());
  }
}

/// Provider for the repository (can be overridden in tests)
@riverpod
UserPreferencesRepository userPreferencesRepository(Ref ref) {
  return FirebaseUserPreferencesRepository(FirebaseFirestore.instance);
}

/// Load user preferences from repository
@riverpod
Future<UserPreferences> userPreferences(Ref ref, String userId) async {
  final repository = ref.watch(userPreferencesRepositoryProvider);
  final prefs = await repository.getUserPreferences(userId);
  return prefs ?? UserPreferences(userId: userId);
}

/// Notifier for updating preferences
@riverpod
class UserPreferencesNotifier extends _$UserPreferencesNotifier {
  @override
  FutureOr<void> build(String userId) {
    return null;
  }

  Future<void> save(UserPreferences prefs) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userPreferencesRepositoryProvider);
      await repository.save(prefs);
    });
  }
}
