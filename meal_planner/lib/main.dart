import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'navigation/app_routes.dart';
import 'providers/meal_providers.dart';
import 'providers/recipe_providers.dart';
import 'repositories/in_memory_meal_repository.dart';
import 'repositories/in_memory_meal_template_repository.dart';
import 'repositories/in_memory_recipe_repository.dart';
import 'screens/calendar/infinite_calendar_screen.dart';
import 'screens/calendar/week_calendar_screen.dart';
import 'screens/debug/developer_launcher_screen.dart';
import 'screens/preferences/user_preferences_screen.dart';
import 'screens/recipe/recipe_list_screen.dart';
import 'screens/splash/animated_splash_screen.dart';


void main() async {
  // Set up error handling
  FlutterError.onError = (details) {
    debugPrint('🔴 FLUTTER ERROR: ${details.exception}');
    debugPrint('Stack trace:\n${details.stack}');
    FlutterError.presentError(details);
  };

  debugPrint('🚀 MealPlanner starting up...');
  debugPrint('   Flutter version: ${const String.fromEnvironment('FLUTTER_VERSION', defaultValue: 'unknown')}');
  debugPrint('   Debug mode: $kDebugMode');
  
  try {
    debugPrint('📱 Initializing Flutter bindings...');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('✅ Flutter bindings initialized');

    // Initialize Firebase
    debugPrint('🔥 Initializing Firebase...');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized successfully');
      debugPrint('   Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    } catch (e) {
      debugPrint('⚠️  Firebase initialization failed: $e');
      debugPrint('   App will continue without Firebase');
    }

    // Use Firestore emulator for development
    if (kDebugMode) {
      debugPrint('🔧 Debug mode: Attempting to connect to Firestore emulator...');
      try {
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        debugPrint('✅ Connected to Firestore emulator at localhost:8080');
      } catch (e) {
        debugPrint('⚠️  Could not connect to Firestore emulator: $e');
        debugPrint('   Using production Firestore (or Firebase not initialized)');
      }
    }

    debugPrint('🎨 Launching app UI...');
    
    // Initialize repositories for demo (with production clock by default)
    final mealRepo = InMemoryMealRepository();
    
    // Seed demo meals only in debug mode
    if (kDebugMode) {
      mealRepo.seedDemoMeals();
    }
    
    final templateRepo = InMemoryMealTemplateRepository();
    final recipeRepo = InMemoryRecipeRepository();
    
    runApp(
      ProviderScope(
        overrides: [
          mealRepositoryProvider.overrideWithValue(mealRepo),
          mealTemplateRepositoryProvider.overrideWithValue(templateRepo),
          recipeRepositoryProvider.overrideWithValue(recipeRepo),
          // Production uses real clock (nowProvider default)
        ],
        child: const MyApp(),
      ),
    );
    debugPrint('✅ App launched successfully');
  } catch (e, stackTrace) {
    debugPrint('🔴 FATAL ERROR during startup: $e');
    debugPrint('Stack trace:\n$stackTrace');
    runApp(ErrorApp(error: e.toString(), stackTrace: stackTrace.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealPlanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: kDebugMode
          ? const DeveloperLauncherScreen()
          : const ProductionSplashScreen(),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _materialRoute(const InfiniteCalendarScreen());
      case AppRoutes.splashPreview:
        return _materialRoute(const SplashPreviewScreen());
      case AppRoutes.weekCalendar:
        return _materialRoute(const WeekCalendarScreen());
      case AppRoutes.recipeList:
        return _materialRoute(const RecipeListScreen());
      case AppRoutes.userPreferences:
        final userId = settings.arguments is String
            ? settings.arguments as String
            : 'debug-user';
        return _materialRoute(UserPreferencesScreen(userId: userId));
      default:
        return _materialRoute(
          UnknownRouteScreen(routeName: settings.name ?? 'unknown'),
        );
    }
  }

  Route<dynamic> _materialRoute(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}

/// Default fallback screen displayed when a route is not yet implemented.
class UnknownRouteScreen extends StatelessWidget {
  final String routeName;

  const UnknownRouteScreen({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Unavailable'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 64, color: Colors.orangeAccent),
              const SizedBox(height: 16),
              Text(
                'No screen is registered for "$routeName".',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Return to the previous screen to continue testing.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 Building HomeScreen...');
    return Scaffold(
      appBar: AppBar(
        title: const Text('MealPlanner'),
      ),
      body: const Center(
        child: Text('Firebase + Riverpod Ready'),
      ),
    );
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
