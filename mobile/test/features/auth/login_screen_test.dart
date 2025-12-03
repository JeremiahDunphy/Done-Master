import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';

@GenerateMocks([AuthProvider])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuthProvider,
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Login'), findsNWidgets(2)); // AppBar and Button
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget); // Login button
  });

  testWidgets('LoginScreen calls login on valid input', (WidgetTester tester) async {
    when(mockAuthProvider.login(any, any)).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(mockAuthProvider.login('test@example.com', 'password')).called(1);
  });

  testWidgets('LoginScreen shows error on login failure', (WidgetTester tester) async {
    when(mockAuthProvider.login(any, any)).thenThrow(Exception('Login failed'));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Trigger frame
    await tester.pump(const Duration(milliseconds: 100)); // Wait for SnackBar animation

    expect(find.text('Login failed: Exception: Login failed'), findsOneWidget);
  });
}
