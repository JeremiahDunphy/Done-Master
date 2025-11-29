import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  User? _user;
  User? get user => _user;

  // Auth
  Future<User> register(String email, String password, String name, String role) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'role': role,
      }),
    );
    
    if (response.statusCode == 200) {
      _user = User.fromJson(jsonDecode(response.body));
      return _user!;
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<User> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      _user = User.fromJson(jsonDecode(response.body));
      return _user!;
    } else {
      throw Exception('Invalid credentials');
    }
  }

  // Photo Upload
  Future<String> uploadPhoto(File file) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    request.files.add(await http.MultipartFile.fromPath('photo', file.path));
    
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);
      return data['photoUrl'];
    } else {
      throw Exception('Failed to upload photo');
    }
  }

  // Geocoding
  Future<Map<String, double>> geocodeZip(String zip) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?postalcode=$zip&country=US&format=json&limit=1');
    final response = await client.get(url, headers: {'User-Agent': 'Done-App/1.0'});
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        return {
          'latitude': double.parse(data[0]['lat']),
          'longitude': double.parse(data[0]['lon']),
        };
      }
    }
    throw Exception('Invalid zip code');
  }

  // Jobs
  Future<List<Job>> getJobs() async {
    final response = await client.get(Uri.parse('$baseUrl/jobs'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Job.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  Future<Job> createJob({
    required String title,
    required String description,
    required double price,
    required double latitude,
    required double longitude,
    required int clientId,
    required List<File> photos,
    String? zipCode,
    String? category,
    List<String>? tags,
    bool isUrgent = false,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/jobs'));
    
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['clientId'] = clientId.toString();
    request.fields['zipCode'] = zipCode ?? '';
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['category'] = category ?? 'General';
    request.fields['isUrgent'] = isUrgent.toString();
    if (tags != null) {
      request.fields['tags'] = tags.join(',');
    }

    for (var photo in photos) {
      request.files.add(await http.MultipartFile.fromPath('photos', photo.path));
    }

    var response = await client.send(request);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseData = await response.stream.bytesToString();
      return Job.fromJson(jsonDecode(responseData));
    } else {
      throw Exception('Failed to create job');
    }
  }

  Future<void> updateJobStatus(int jobId, String status) async {
    await client.patch(
      Uri.parse('$baseUrl/jobs/$jobId/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );
  }

  // Reviews
  Future<void> createReview(int jobId, int revieweeId, int rating, String comment) async {
    if (_user == null) {
      throw Exception('User not logged in');
    }
    await client.post(
      Uri.parse('$baseUrl/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'jobId': jobId,
        'reviewerId': _user!.id,
        'revieweeId': revieweeId,
        'rating': rating,
        'comment': comment,
      }),
    );
  }

  Future<List<Review>> getUserReviews(int userId) async {
    final response = await client.get(Uri.parse('$baseUrl/users/$userId/reviews'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    }
    return [];
  }

  // Saved Jobs
  Future<void> toggleSaveJob(int jobId) async {
    if (_user == null) {
      throw Exception('User not logged in');
    }
    await client.post(
      Uri.parse('$baseUrl/saved-jobs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': _user!.id, 'jobId': jobId}),
    );
  }

  Future<List<int>> getSavedJobIds() async {
    if (_user == null) {
      throw Exception('User not logged in');
    }
    final response = await client.get(Uri.parse('$baseUrl/saved-jobs/${_user!.id}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<int>();
    }
    return [];
  }

  // Notifications
  Future<List<AppNotification>> getNotifications() async {
    if (_user == null) {
      throw Exception('User not logged in');
    }
    final response = await client.get(Uri.parse('$baseUrl/notifications/${_user!.id}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AppNotification.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> markNotificationRead(int id) async {
    await client.post(Uri.parse('$baseUrl/notifications/$id/read'));
  }

  Future<void> applyForJob(int jobId, int providerId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/jobs/$jobId/apply'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'providerId': providerId}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to apply for job');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(int jobId, double amount) async {
    final response = await client.post(
      Uri.parse('$baseUrl/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jobId': jobId,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create payment intent');
    }
  }

  // Messaging
  Future<List<Conversation>> getConversations(int userId) async {
    final response = await client.get(Uri.parse('$baseUrl/conversations/$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<List<Message>> getMessages(int userId, int otherUserId) async {
    final response = await client.get(Uri.parse('$baseUrl/messages/$userId/$otherUserId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }
}
