import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/jobs/screens/jobs_screen.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/models/models.dart';

@GenerateMocks([AuthProvider, ApiService])
import 'jobs_screen_test.mocks.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockApiService = MockApiService();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        Provider<ApiService>.value(value: mockApiService),
      ],
      child: const MaterialApp(
        home: JobsScreen(),
      ),
    );
  }

  testWidgets('JobsScreen renders list of jobs', (WidgetTester tester) async {
    // Mock Auth
    when(mockAuthProvider.user).thenReturn(User(id: 1, email: 'test@test.com', name: 'Test', role: 'POSTER'));
    when(mockAuthProvider.isAuthenticated).thenReturn(true);

    // Mock ApiService
    when(mockApiService.getSavedJobIds()).thenAnswer((_) async => []);
    when(mockApiService.getJobs()).thenAnswer((_) async => [
      Job(
        id: 1,
        title: 'Test Job 1',
        description: 'Description 1',
        price: 100.0,
        latitude: 0.0,
        longitude: 0.0,
        status: 'OPEN',
        posterId: 1,
        photos: [],
        category: 'General',
        zipCode: '12345',
        createdAt: DateTime.now(),
      ),
      Job(
        id: 2,
        title: 'Test Job 2',
        description: 'Description 2',
        price: 200.0,
        latitude: 0.0,
        longitude: 0.0,
        status: 'OPEN',
        posterId: 1,
        photos: [],
        category: 'General',
        zipCode: '12345',
        createdAt: DateTime.now(),
      ),
    ]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Trigger initState
    await tester.pump(); // Trigger FutureBuilder/setState

    expect(find.text('Test Job 1'), findsOneWidget);
    expect(find.text('Test Job 2'), findsOneWidget);
    expect(find.text('\$100.00/day'), findsOneWidget);
  });

  testWidgets('JobsScreen shows error on failure', (WidgetTester tester) async {
    when(mockAuthProvider.user).thenReturn(User(id: 1, email: 'test@test.com', name: 'Test', role: 'POSTER'));
    when(mockApiService.getSavedJobIds()).thenAnswer((_) async => []);
    when(mockApiService.getJobs()).thenThrow(Exception('Failed to load'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100)); // SnackBar animation

    expect(find.text('Failed to load jobs: Exception: Failed to load'), findsOneWidget);
  });
}
