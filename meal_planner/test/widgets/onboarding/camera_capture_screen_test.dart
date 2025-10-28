import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/screens/onboarding/camera_capture_screen.dart';

void main() {
  group('CameraCaptureScreen', () {
    testWidgets('displays camera preview placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraCaptureScreen(),
        ),
      );

      expect(find.text('Camera preview would appear here'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('shows capture button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraCaptureScreen(),
        ),
      );

      expect(find.text('Capture Photo'), findsOneWidget);
      expect(find.byIcon(Icons.camera), findsOneWidget);
    });

    testWidgets('shows gallery button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraCaptureScreen(),
        ),
      );

      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });

    testWidgets('shows flash toggle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraCaptureScreen(),
        ),
      );

      expect(find.byIcon(Icons.flash_off), findsOneWidget);
    });

    testWidgets('tap capture button shows captured image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraCaptureScreen(),
        ),
      );

      await tester.tap(find.text('Capture Photo'));
      await tester.pump();

      expect(find.text('Captured Image'), findsOneWidget);
      expect(find.text('Retake'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('tap gallery button shows captured image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraCaptureScreen(),
        ),
      );

      await tester.tap(find.text('Choose from Gallery'));
      await tester.pump();

      expect(find.text('Captured Image'), findsOneWidget);
    });

    testWidgets('tap retake button returns to camera', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraCaptureScreen(),
        ),
      );

      // Capture a photo
      await tester.tap(find.text('Capture Photo'));
      await tester.pump();

      // Tap retake
      await tester.tap(find.text('Retake'));
      await tester.pump();

      // Should be back to camera view
      expect(find.text('Camera preview would appear here'), findsOneWidget);
    });

    testWidgets('tap confirm button pops with image path', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraCaptureScreen(),
                      ),
                    );
                  },
                  child: const Text('Open Camera'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open camera screen
      await tester.tap(find.text('Open Camera'));
      await tester.pumpAndSettle();

      // Capture photo
      await tester.tap(find.text('Capture Photo'));
      await tester.pump();

      // Confirm
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Should have returned with image path
      expect(result, isNotNull);
      expect(result, startsWith('mock://'));
    });
  });
}
