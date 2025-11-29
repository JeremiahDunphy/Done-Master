import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/models/models.dart';
import 'dart:convert';

// Generate mocks
@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiService = ApiService(client: mockClient);
    });

    test('login returns User on success', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
          jsonEncode({'id': 1, 'email': 'test@test.com', 'name': 'Test', 'role': 'POSTER'}), 200));

      final user = await apiService.login('test@test.com', 'password');
      expect(user, isNotNull);
      expect(user!.email, 'test@test.com');
    });

    test('getJobs returns list of Jobs', () async {
      when(mockClient.get(any)).thenAnswer((_) async => http.Response(
          jsonEncode([
            {
              'id': 1,
              'title': 'Job 1',
              'description': 'Desc',
              'price': 100.0,
              'latitude': 0.0,
              'longitude': 0.0,
              'status': 'OPEN',
              'clientId': 1,
              'photos': 'url1',
              'category': 'General',
              'createdAt': DateTime.now().toIso8601String()
            }
          ]),
          200));

      final jobs = await apiService.getJobs();
      expect(jobs.length, 1);
      expect(jobs.first.title, 'Job 1');
    });

    test('createJob sends multipart request', () async {
      // Mocking send for MultipartRequest is complex with just MockClient
      // We will verify it calls send and returns success
      final stream = http.ByteStream.fromBytes(utf8.encode(jsonEncode({
        'id': 1,
        'title': 'New Job',
        'description': 'Desc',
        'price': 100.0,
        'latitude': 0.0,
        'longitude': 0.0,
        'status': 'OPEN',
        'clientId': 1,
        'photos': 'url1',
        'isUrgent': false,
        'category': 'General',
        'createdAt': DateTime.now().toIso8601String()
      })));
      
      when(mockClient.send(any)).thenAnswer((_) async => http.StreamedResponse(
        stream,
        200,
      ));

      final createdJob = await apiService.createJob(
        title: 'New Job',
        description: 'Desc',
        price: 100.0,
        latitude: 0.0,
        longitude: 0.0,
        posterId: 1,
        photos: [],
        isUrgent: false,
        category: 'General',
        zipCode: '12345',
      );
      expect(createdJob.title, 'New Job');
    });

    test('createPaymentIntent returns client secret', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
          jsonEncode({'clientSecret': 'secret_123'}), 200));

      final result = await apiService.createPaymentIntent(1, 100.0);
      expect(result['clientSecret'], 'secret_123');
    });

    test('getNotifications returns list', () async {
      // Mock user login first or inject user? ApiService has private _user.
      // We can't easily set _user in test without modifying ApiService or mocking login.
      // For this test, we'll assume login was called or we'll mock login first.
      
      // Mock login response
      when(mockClient.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
          jsonEncode({'id': 1, 'email': 'test@test.com', 'name': 'Test', 'role': 'POSTER'}), 200));
      
      await apiService.login('test@test.com', 'password');

      when(mockClient.get(Uri.parse('${ApiService.baseUrl}/notifications/1')))
          .thenAnswer((_) async => http.Response(
          jsonEncode([
            {'id': 1, 'message': 'Msg', 'read': false, 'createdAt': DateTime.now().toIso8601String()}
          ]), 200));

      final notifications = await apiService.getNotifications();
      expect(notifications.length, 1);
      expect(notifications.first.message, 'Msg');
    });

    test('applyForJob sends request', () async {
      when(mockClient.post(
        Uri.parse('${ApiService.baseUrl}/jobs/1/apply'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      await apiService.applyForJob(1, 2);
    });

    test('updateJobStatus sends patch request', () async {
      when(mockClient.patch(
        Uri.parse('${ApiService.baseUrl}/jobs/1/status'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      await apiService.updateJobStatus(1, 'IN_PROGRESS');
    });

    test('createReview sends post request', () async {
      // Ensure logged in
      when(mockClient.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
          jsonEncode({'id': 1, 'email': 'test@test.com', 'name': 'Test', 'role': 'POSTER'}), 200));
      await apiService.login('test@test.com', 'password');

      when(mockClient.post(
        Uri.parse('${ApiService.baseUrl}/reviews'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      await apiService.createReview(1, 2, 5, 'Great');
    });

    test('getUserReviews returns list', () async {
      when(mockClient.get(Uri.parse('${ApiService.baseUrl}/users/1/reviews')))
          .thenAnswer((_) async => http.Response(
          jsonEncode([
            {'id': 1, 'jobId': 1, 'reviewerId': 2, 'revieweeId': 1, 'rating': 5, 'comment': 'Good', 'createdAt': DateTime.now().toIso8601String()}
          ]), 200));

      final reviews = await apiService.getUserReviews(1);
      expect(reviews.length, 1);
      expect(reviews.first.rating, 5);
    });

    test('toggleSaveJob sends post request', () async {
      // Ensure logged in
      when(mockClient.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
          jsonEncode({'id': 1, 'email': 'test@test.com', 'name': 'Test', 'role': 'POSTER'}), 200));
      await apiService.login('test@test.com', 'password');

      when(mockClient.post(
        Uri.parse('${ApiService.baseUrl}/saved-jobs'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      await apiService.toggleSaveJob(1);
    });

    test('getSavedJobIds returns list', () async {
      // Ensure logged in
      when(mockClient.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
          jsonEncode({'id': 1, 'email': 'test@test.com', 'name': 'Test', 'role': 'POSTER'}), 200));
      await apiService.login('test@test.com', 'password');

      when(mockClient.get(Uri.parse('${ApiService.baseUrl}/saved-jobs/1')))
          .thenAnswer((_) async => http.Response('[1, 2, 3]', 200));

      final ids = await apiService.getSavedJobIds();
      expect(ids.length, 3);
      expect(ids.first, 1);
    });

    test('markNotificationRead sends post request', () async {
      when(mockClient.post(Uri.parse('${ApiService.baseUrl}/notifications/1/read')))
          .thenAnswer((_) async => http.Response('{}', 200));

      await apiService.markNotificationRead(1);
    });
  });
}
