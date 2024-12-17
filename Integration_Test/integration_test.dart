import 'package:flutter_test/flutter_test.dart';
import 'package:hedieatymobileapplication/Views/SplashScreen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieatymobileapplication/main.dart' as app; // Import your app entry point
import 'package:flutter/material.dart';
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('App Integration Tests', () {
    testWidgets('Integration Test 1', (WidgetTester tester) async {

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
        //Navigate to friend event list
        await tester.tap(find.text("Samehh"));
        await tester.pumpAndSettle(Duration(seconds: 5));
        //navigate to event gift list
        await tester.tap(find.text("dhehh"));
        await tester.pumpAndSettle(Duration(seconds: 5));
        //navigate to gift details
        await tester.tap(find.text("Jacket"));
        await tester.pumpAndSettle(Duration(seconds: 5));
        //search for pledge/cancel button and tap on it
        final listViewFinder = find.byKey(Key('GiftDetailsListView'));
        final pledgeButtonFinder = find.byKey(Key('PledgeButton')); // Target the button
        // Scroll until the button becomes visible
        await tester.drag(listViewFinder, const Offset(0, -800)); // Scroll down
        await tester.pumpAndSettle(Duration(seconds: 3));
        //press the button
        await tester.tap(pledgeButtonFinder);
        await tester.pumpAndSettle(Duration(seconds: 5));

        //ensure gift pledged, when gift is pledged/cancelled the user is navigated to the gift list again
        expect(find.text('Gifts for dhehh'), findsOneWidget);


      });

  });
}
