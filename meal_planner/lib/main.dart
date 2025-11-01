import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'repositories/in_memory_meal_repository.dart';
import 'repositories/firestore_meal_repository.dart';
import 'providers/meal_providers.dart';
import 'screens/calendar/infinite_calendar_screen.dart';
import 'screens/entry/entry_screens.dart';


void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve native splash screen during initialization
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Decide backend
  const useFirebase = bool.fromEnvironment('USE_FIREBASE');
  final isProd = useFirebase || kReleaseMode;

  if (isProd) {
    await Firebase.initializeApp();
  }

  final overrides = <Override>[];
  if (isProd) {
    overrides.add(
      mealRepositoryProvider.overrideWithValue(FirestoreMealRepository()),
    );
  } else {
    final mealRepo = InMemoryMealRepository()..seedDemoMeals();
    overrides.add(
      mealRepositoryProvider.overrideWithValue(mealRepo),
    );
  }

  final entryMode = _resolveEntryMode();
  debugPrint('APP_ENTRY_MODE=$entryMode');

  // Remove native splash before showing Flutter UI
  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      overrides: overrides,
      child: MyApp(entryMode: entryMode),
    ),
  );
}

EntryMode _resolveEntryMode() {
  if (kReleaseMode) {
    return EntryMode.productionSplash;
  }
  return EntryMode.debugLauncher;
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.entryMode,
  });

  final EntryMode entryMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealPlanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: _initialRoute(),
      routes: {
        AppRoutes.splash: (_) => ProductionSplashScreen(nextRoute: AppRoutes.rotateHint),
        AppRoutes.home: (_) => const InfiniteCalendarScreen(),
        AppRoutes.developerLauncher: (_) => const DeveloperLauncherScreen(),
        AppRoutes.splashPreview: (_) => const SplashPreviewScreen(),
        AppRoutes.rotateHint: (_) => const RotateHintScreen(),
      },
    );
  }

  String _initialRoute() {
    switch (entryMode) {
      case EntryMode.productionSplash:
        return AppRoutes.splash;
      case EntryMode.debugLauncher:
        return AppRoutes.developerLauncher;
    }
  }
}

/// Error screen displayed when the app fails to initialize
class ErrorApp extends StatelessWidget {
  final String error;
  final String? stackTrace;
  
  const ErrorApp({super.key, required this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.error_outline, size: 72, color: Colors.red.shade700),
                const SizedBox(height: 24),
                Text(
                  'Startup Error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: SelectableText(
                    error,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
                if (stackTrace != null) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text('Stack Trace'),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          stackTrace!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Check the console for detailed logs',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
