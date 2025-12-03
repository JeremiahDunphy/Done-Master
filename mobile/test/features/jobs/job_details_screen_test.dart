import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/jobs/screens/job_details_screen.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/models/models.dart';
@GenerateMocks([AuthProvider, ApiService])
import 'job_details_screen_test.mocks.dart';

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

  Widget createWidgetUnderTest(Job job) {
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
                  MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)),
                ),
                child: const Text('Go to Job Details'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final testJob = Job(
    id: 1,
    title: 'Test Job',
    description: 'Description',
    price: 100.0,
    latitude: 37.77,
    longitude: -122.41,
    status: 'OPEN',
    posterId: 1,
    photos: [],
    zipCode: '94102',
    category: 'General',
    createdAt: DateTime.now(),
  );

  testWidgets('JobDetailsScreen renders job details', (WidgetTester tester) async {
    when(mockAuthProvider.user).thenReturn(User(id: 2, email: 'client@test.com', name: 'Client', role: 'POSTER'));

    await tester.pumpWidget(createWidgetUnderTest(testJob));

    await tester.tap(find.text('Go to Job Details'));
    await tester.pumpAndSettle();

    expect(find.text('Test Job'), findsNWidgets(2));
    expect(find.text('Description'), findsNWidgets(2));
    expect(find.text('\$100.00/day'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
  });

  testWidgets('JobDetailsScreen shows Apply button for PRO user', (WidgetTester tester) async {
    when(mockAuthProvider.user).thenReturn(User(id: 2, email: 'pro@test.com', name: 'Pro', role: 'DOER'));

    await tester.pumpWidget(createWidgetUnderTest(testJob));

    await tester.tap(find.text('Go to Job Details'));
    await tester.pumpAndSettle();

    expect(find.text('Apply Now'), findsOneWidget);
  });

  testWidgets('JobDetailsScreen hides Apply button for CLIENT user', (WidgetTester tester) async {
    when(mockAuthProvider.user).thenReturn(User(id: 2, email: 'client@test.com', name: 'Client', role: 'POSTER'));

    await tester.pumpWidget(createWidgetUnderTest(testJob));

    await tester.tap(find.text('Go to Job Details'));
    await tester.pumpAndSettle();

    expect(find.text('Apply Now'), findsNothing);
  });

  testWidgets('JobDetailsScreen applies to job successfully', (WidgetTester tester) async {
    when(mockAuthProvider.user).thenReturn(User(id: 2, email: 'pro@test.com', name: 'Pro', role: 'DOER'));
    when(mockApiService.applyForJob(1, 2)).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest(testJob));

    await tester.tap(find.text('Go to Job Details'));
    await tester.pumpAndSettle();

    final applyButtonFinder = find.text('Apply Now');
    await tester.ensureVisible(applyButtonFinder);
    await tester.tap(applyButtonFinder);
    await tester.pumpAndSettle();

    verify(mockApiService.applyForJob(1, 2)).called(1);

    expect(find.text('Application submitted!'), findsOneWidget);
  });
}


class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest();
  }
  
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return MockHttpClientRequest();
  }
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse();
  }
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([kTransparentImage]).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

const List<int> kTransparentImage = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];
