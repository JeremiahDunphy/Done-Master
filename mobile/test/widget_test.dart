import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/shared/services/api_service.dart';

void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          Provider(create: (_) => ApiService()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify that the title is present
    expect(find.text('Done'), findsOneWidget);
    
    // Verify email and password fields are present
    expect(find.byType(TextField), findsNWidgets(2));
    
    // Verify Login button is present
    expect(find.text('Login'), findsNWidgets(2)); // AppBar and Button
  });
}
