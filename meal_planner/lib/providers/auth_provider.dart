import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
String? currentUserId(CurrentUserIdRef ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}

@riverpod
class AuthInitializerNotifier extends _$AuthInitializerNotifier {
  @override
  FutureOr<void> build() async {
    await _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      try {
        await auth.signInAnonymously();
      } catch (e) {
        print('Error signing in anonymously: $e');
        rethrow;
      }
    }
  }
}
