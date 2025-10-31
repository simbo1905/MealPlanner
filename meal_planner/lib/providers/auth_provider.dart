import 'package:flutter_riverpod/flutter_riverpod.dart';

const _defaultUserId = 'integration-test-user';

/// Provides the currently signed-in user's ID (nullable for unauthenticated).
/// For now, returns a fixed test user id to keep the app functional.
final currentUserIdProvider = Provider<String?>((ref) {
  const isIntegration = bool.fromEnvironment('INTEGRATION_TEST');
  if (isIntegration) {
    return _defaultUserId;
  }
  // TODO: Wire up FirebaseAuth and return null when signed-out.
  return _defaultUserId;
});
