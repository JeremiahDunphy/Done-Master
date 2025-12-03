import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/models/models.dart';
import 'dart:convert';

@GenerateMocks([http.Client])
import 'job_service_test.mocks.dart';

void main() {
  late ApiService apiService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService(client: mockClient);
  });

  group('Job Service Tests', () {
    test('getJobs returns list of jobs on success', () async {
      final jobsJson = [
        {
          'id': 1,
          'title': 'Test Job',
          'description': 'Description',
          'price': 100.0,
          'latitude': 37.77,
          'longitude': -122.41,
          'status': 'OPEN',
          'clientId': 1,
          'photos': '',
          'zipCode': '94102',
          'isUrgent': false,
          'category': 'General',
          'createdAt': DateTime.now().toIso8601String(),
        }
      ];

      when(mockClient.get(Uri.parse('http://localhost:3000/jobs')))
          .thenAnswer((_) async => http.Response(jsonEncode(jobsJson), 200));

      final jobs = await apiService.getJobs();

      expect(jobs, isA<List<Job>>());
      expect(jobs.length, 1);
      expect(jobs.first.title, 'Test Job');
    });

    test('getJobs throws exception on failure', () async {
      when(mockClient.get(Uri.parse('http://localhost:3000/jobs')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(apiService.getJobs(), throwsException);
    });

    test('applyForJob makes correct post request', () async {
      when(mockClient.post(
        Uri.parse('http://localhost:3000/jobs/1/apply'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'providerId': 2}),
      )).thenAnswer((_) async => http.Response('{}', 200));

      await apiService.applyForJob(1, 2);

      verify(mockClient.post(
        Uri.parse('http://localhost:3000/jobs/1/apply'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'providerId': 2}),
      )).called(1);
    });

    test('applyForJob throws exception on failure', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 500));

      expect(apiService.applyForJob(1, 2), throwsException);
    });
  });
}
