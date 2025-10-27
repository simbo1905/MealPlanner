import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_preferences.freezed_model.dart';

part 'user_preferences_providers.g.dart';

// Load user preferences from Firestore
@riverpod
Future<UserPreferences> userPreferences(
  Ref ref,
  String userId,
) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('user_preferences')
        .doc(userId)
        .get();
    if (doc.exists) {
      return UserPreferences.fromJson({...doc.data()!, 'userId': userId});
    }
    // Return defaults
    return UserPreferences(userId: userId);
  } catch (e) {
    return UserPreferences(userId: userId);
  }
}

// Notifier for updating preferences
@riverpod
class UserPreferencesNotifier extends _$UserPreferencesNotifier {
  @override
  FutureOr<void> build(String userId) {
    return null;
  }

  Future<void> updatePortions(int portions) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(userId)
          .update({'portions': portions});
    });
  }

  Future<void> addDietaryRestriction(String restriction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(userId)
          .update({
        'dietaryRestrictions': FieldValue.arrayUnion([restriction])
      });
    });
  }

  Future<void> save(UserPreferences prefs) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(userId)
          .set(prefs.toJson());
    });
  }
}
