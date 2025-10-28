import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

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
    runApp(const ProviderScope(child: MyApp()));
    debugPrint('✅ App launched successfully');
  } catch (e, stackTrace) {
    debugPrint('🔴 FATAL ERROR during startup: $e');
    debugPrint('Stack trace:\n$stackTrace');
    runApp(ErrorApp(error: e.toString(), stackTrace: stackTrace.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealPlanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
  
  const ErrorApp({Key? key, required this.error, this.stackTrace}) : super(key: key);

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
