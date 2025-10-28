import 'dart:io';

// Clears Firestore emulator data between tests to keep isolation.
// Safe to call even if emulator isn't running; errors are swallowed.
Future<void> clearFirestoreEmulator({
  String host = 'localhost',
  int port = 8080,
  required String projectId,
}) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse(
      'http://$host:$port/emulator/v1/projects/$projectId/databases/(default)/documents',
    );
    final request = await client.deleteUrl(uri);
    final response = await request.close();
    // Drain the response to complete the request.
    await response.drain();
  } catch (_) {
    // Ignore errors so tests don't fail if emulator isn't running.
  } finally {
    client.close(force: true);
  }
}

