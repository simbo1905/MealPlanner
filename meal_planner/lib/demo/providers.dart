import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a function returning the current time. Tests can override this
/// to ensure deterministic behavior, e.g. a fixed date.
final nowProvider = Provider<DateTime Function()>((ref) {
  return () => DateTime.now();
});

/// Flag to control whether demo seeding is enabled.
/// Default enables seeding in debug mode; tests can override explicitly.
final demoSeedingEnabledProvider = Provider<bool>((ref) {
  return kDebugMode;
});

