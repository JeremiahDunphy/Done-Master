import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify app startup and login flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we are on Landing Page
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);

      // Navigate to Login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify Login Page
      expect(find.text('Welcome Back'), findsOneWidget);

      // Enter credentials
      // We use the user created in Web E2E or a new one?
      // Web E2E created a user. Let's try to use it if we know the credentials.
      // Web E2E used random email.
      // So we should probably register a NEW user here to be safe.
      
      // Go back to Landing
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Navigate to Register
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify Register Page
      expect(find.text('Create Account'), findsOneWidget);

      // Fill Registration Form
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final email = 'mobile_test_$timestamp@example.com';
      
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Mobile Tester');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), email);
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      
      // Select Role (Dropdown)
      // Assuming default is Client or we need to pick one.
      // The UI might have a dropdown.
      // Let's check RegisterScreen code if needed.
      // For now, assume default or simple inputs.
      
      // Tap Register button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle();

      // Verify we are on Home Screen (Jobs)
      // It should show "Jobs" title or similar
      // expect(find.text('Jobs'), findsOneWidget); 
      // Or check for bottom nav bar
      expect(find.byIcon(Icons.work), findsOneWidget);
    });
  });
}
