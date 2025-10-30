import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

@riverpod
String? currentUserId(CurrentUserIdRef ref) {
  final auth = ref.watch(authStateProvider);
  return auth.when(
    data: (user) => user?.uid,
    loading: () => null,
    error: (_, __) => null,
  );
}

@riverpod
Future<void> ensureSignedIn(EnsureSignedInRef ref) async {
  final auth = FirebaseAuth.instance;
  final currentUser = auth.currentUser;
  if (currentUser != null) {
    return;
  }
  await auth.signInAnonymously();
}