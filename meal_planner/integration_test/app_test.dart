import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meal_planner/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App starts and displays Hello World', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    expect(find.text('Hello World'), findsOneWidget);
    expect(find.text('Flutter + CloudKit'), findsOneWidget);
  });
}
