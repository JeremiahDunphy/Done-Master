import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/models/models.dart';

void main() {
  group('User Model', () {
    test('fromJson creates correct User object', () {
      final json = {
        'id': 1,
        'email': 'test@example.com',
        'name': 'Test User',
        'role': 'POSTER'
      };
      final user = User.fromJson(json);
      expect(user.id, 1);
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.role, 'POSTER');
    });
  });

  group('Job Model', () {
    test('fromJson creates correct Job object', () {
      final json = {
        'id': 101,
        'title': 'Fix Sink',
        'description': 'Leaky faucet',
        'price': 50.0,
        'latitude': 37.7749,
        'longitude': -122.4194,
        'status': 'OPEN',
        'photos': 'url1,url2',
        'clientId': 1,
        'category': 'General',
        'createdAt': DateTime.now().toIso8601String()
      };
      final job = Job.fromJson(json);
      expect(job.id, 101);
      expect(job.title, 'Fix Sink');
      expect(job.price, 50.0);
      expect(job.photos.length, 2);
    });
  });

  group('Review Model', () {
    test('fromJson creates correct Review object', () {
      final json = {
        'id': 1,
        'rating': 5,
        'comment': 'Great!',
        'reviewerId': 10,
        'revieweeId': 20
      };
      final review = Review.fromJson(json);
      expect(review.id, 1);
      expect(review.rating, 5);
      expect(review.comment, 'Great!');
    });
  });

  group('AppNotification Model', () {
    test('fromJson creates correct Notification object', () {
      final now = DateTime.now().toIso8601String();
      final json = {
        'id': 1,
        'message': 'New Job',
        'read': false,
        'createdAt': now
      };
      final notification = AppNotification.fromJson(json);
      expect(notification.id, 1);
      expect(notification.message, 'New Job');
      expect(notification.read, false);
    });
  });
}
