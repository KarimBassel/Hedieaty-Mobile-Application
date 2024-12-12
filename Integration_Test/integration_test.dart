import 'package:flutter_test/flutter_test.dart';
import 'package:hedieatymobileapplication/Views/SplashScreen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieatymobileapplication/main.dart' as app; // Import your app entry point
import 'package:flutter/material.dart';
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('App Integration Tests', () {
    testWidgets('Sign in test', (WidgetTester tester) async {

        app.main();

         await tester.pumpAndSettle(Duration(seconds: 10));
        final emailField = find.byKey(Key("emailField"));
        final passwordField = find.byKey(Key('passwordField'));
        final signInButton = find.byKey(Key('signInButton'));


        await tester.enterText(emailField, 'karimbassel15@gmail.com');
        await tester.enterText(passwordField, '123456');
        await tester.ensureVisible(signInButton);
        await tester.tap(signInButton);
        await tester.pumpAndSettle(Duration(seconds: 10));
        expect(find.text('Create your own Event'), findsOneWidget);
      });

  });
}
