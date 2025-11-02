import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meal_planner/screens/entry/entry_screens.dart';

void main() {
  group('Entry flow', () {
    testWidgets('shows production splash then navigates to home', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (_) => const ProductionSplashScreen(
                  nextRoute: AppRoutes.home,
                  minimumDisplayDuration: Duration(milliseconds: 10),
                ),
            AppRoutes.home: (_) => const _TestHome(),
          },
        ),
      );

      expect(find.byType(ProductionSplashScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Image && widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == 'assets/splash_logo.png',
        ),
        findsOneWidget,
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProductionSplashScreen), findsNothing);
      expect(find.byType(_TestHome), findsOneWidget);
    });

    testWidgets('developer launcher exposes navigation options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DeveloperLauncherScreen(),
          routes: {
            AppRoutes.home: (_) => const _TestHome(),
            AppRoutes.splashPreview: (_) => const _TestPlaceholder(title: 'Splash Preview'),
          },
        ),
      );

      expect(find.text('Developer Launcher'), findsOneWidget);
      expect(find.text('Go to Home Screen'), findsOneWidget);
      expect(find.text('Preview Splash Animation'), findsOneWidget);

      await tester.tap(find.text('Go to Home Screen'));
      await tester.pumpAndSettle();

      expect(find.byType(_TestHome), findsOneWidget);
    });
  });
}

class _TestHome extends StatelessWidget {
  const _TestHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home Placeholder', key: Key('home-placeholder'))),
    );
  }
}

class _TestPlaceholder extends StatelessWidget {
  const _TestPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Placeholder')), 
    );
  }
}
