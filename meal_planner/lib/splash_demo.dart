import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'screens/entry/entry_screens.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  FlutterNativeSplash.remove();

  runApp(const SplashDemoApp());
}

class SplashDemoApp extends StatelessWidget {
  const SplashDemoApp({super.key});

  static const _finishedRoute = '/demo-finished';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Splash Demo',
      theme: ThemeData(useMaterial3: true),
      routes: {
        '/': (_) => const ProductionSplashScreen(
              nextRoute: _finishedRoute,
              minimumDisplayDuration: Duration(seconds: 4),
            ),
        _finishedRoute: (_) => const _SplashDemoFinishedScreen(),
      },
      initialRoute: '/',
    );
  }
}

class _SplashDemoFinishedScreen extends StatelessWidget {
  const _SplashDemoFinishedScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 96,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'Splash Demo Finished',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'This standalone build renders the production splash without loading the full MealPlanner app.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

