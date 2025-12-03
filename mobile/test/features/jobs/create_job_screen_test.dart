import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/jobs/screens/create_job_screen.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/models/models.dart';
import 'dart:io';

@GenerateMocks([AuthProvider, ApiService])
import 'create_job_screen_test.mocks.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockApiService = MockApiService();

    // Stub ChangeNotifier methods
    when(mockAuthProvider.addListener(any)).thenReturn(null);
    when(mockAuthProvider.removeListener(any)).thenReturn(null);
    when(mockAuthProvider.hasListeners).thenReturn(false);
    when(mockAuthProvider.notifyListeners()).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuthProvider,
      child: Provider<ApiService>.value(
        value: mockApiService,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateJobScreen()),
                ),
                child: const Text('Go to Create Job'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Sanity check', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Hello'))));
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('CreateJobScreen renders form fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Go to Create Job'));
    await tester.pumpAndSettle();

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Price per Day'), findsOneWidget);
    expect(find.text('Zip Code'), findsOneWidget);
    expect(find.text('Create Job'), findsNWidgets(2)); // AppBar and Button
  });

  testWidgets('CreateJobScreen shows error on invalid zip', (WidgetTester tester) async {
    when(mockAuthProvider.user).thenReturn(User(id: 1, email: 'test@test.com', name: 'Test', role: 'POSTER'));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Go to Create Job'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Test Job');
    await tester.enterText(find.widgetWithText(TextField, 'Description'), 'Description');
    await tester.enterText(find.widgetWithText(TextField, 'Price per Day'), '100');
    await tester.enterText(find.widgetWithText(TextField, 'Zip Code'), '123'); // Invalid zip length
    await tester.pumpAndSettle();

    final buttonFinder = find.widgetWithText(ElevatedButton, 'Create Job');
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Please enter a valid 5-digit zip code'), findsOneWidget);
  });

  testWidgets('CreateJobScreen submits job on valid input', (WidgetTester tester) async {
    when(mockAuthProvider.user).thenReturn(User(id: 1, email: 'test@test.com', name: 'Test', role: 'POSTER'));
    when(mockApiService.geocodeZip('94102')).thenAnswer((_) async => {'latitude': 37.77, 'longitude': -122.41});
    when(mockApiService.createJob(
      title: anyNamed('title'),
      description: anyNamed('description'),
      price: anyNamed('price'),
      latitude: anyNamed('latitude'),
      longitude: anyNamed('longitude'),
      posterId: anyNamed('posterId'),
      photos: anyNamed('photos'),
      zipCode: anyNamed('zipCode'),
      isUrgent: anyNamed('isUrgent'),
    )).thenAnswer((_) async => Job(
      id: 1,
      title: 'Test Job',
      description: 'Description',
      price: 100.0,
      latitude: 37.77,
      longitude: -122.41,
      status: 'OPEN',
      posterId: 1,
      photos: [],
      category: 'General',
      zipCode: '94102',
      createdAt: DateTime.now(),
    ));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Go to Create Job'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Test Job');
    await tester.enterText(find.widgetWithText(TextField, 'Description'), 'Description');
    await tester.enterText(find.widgetWithText(TextField, 'Price per Day'), '100');
    await tester.enterText(find.widgetWithText(TextField, 'Zip Code'), '94102');
    await tester.pumpAndSettle();

    final buttonFinder = find.widgetWithText(ElevatedButton, 'Create Job');
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Check if geocode was called
    verify(mockApiService.geocodeZip('94102')).called(1);

    verify(mockApiService.createJob(
      title: anyNamed('title'),
      description: anyNamed('description'),
      price: anyNamed('price'),
      latitude: anyNamed('latitude'),
      longitude: anyNamed('longitude'),
      posterId: anyNamed('posterId'),
      photos: anyNamed('photos'),
      zipCode: anyNamed('zipCode'),
      isUrgent: anyNamed('isUrgent'),
    )).called(1);

    expect(find.text('Job created successfully!'), findsOneWidget);
  });
}
