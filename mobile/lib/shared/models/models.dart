class User {
  final int id;
  final String email;
  final String name;
  final String role;
  final bool isElite;
  final int jobsCompleted;
  final double averageRating;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isElite = false,
    this.jobsCompleted = 0,
    this.averageRating = 0.0,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'] ?? '',
      role: json['role'],
      isElite: json['isElite'] ?? false,
      jobsCompleted: json['jobsCompleted'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      profileImage: json['profileImage'],
    );
  }
}

class Job {
  final int id;
  final int posterId;
  final int? doerId;
  final String title;
  final String description;
  final double price;
  final String category;
  final String? tags;
  final User? poster;
  final User? doer;
  final String status;
  final DateTime createdAt;
  final String zipCode;
  final double? latitude;
  final double? longitude;
  final DateTime? scheduledDate;
  final List<String> photos;

  Job({
    required this.id,
    required this.posterId,
    this.doerId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.tags,
    this.poster,
    this.doer,
    required this.status,
    required this.createdAt,
    required this.zipCode,
    this.latitude,
    this.longitude,
    this.scheduledDate,
    this.photos = const [],
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      posterId: json['clientId'], 
      doerId: json['providerId'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      tags: json['tags'],
      poster: json['client'] != null ? User.fromJson(json['client']) : null,
      doer: json['provider'] != null ? User.fromJson(json['provider']) : null,
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      zipCode: json['zipCode'] ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate']) : null,
      photos: json['photos'] != null ? (json['photos'] as String).split(',').where((s) => s.isNotEmpty).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': posterId,
      'providerId': doerId,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'tags': tags,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'zipCode': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'photos': photos.join(','),
    };
  }
}

class Review {
  final int id;
  final int rating;
  final String comment;
  final int reviewerId;
  final int revieweeId;

  Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.reviewerId,
    required this.revieweeId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      reviewerId: json['reviewerId'],
      revieweeId: json['revieweeId'],
    );
  }
}

class AppNotification {
  final int id;
  final String message;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      message: json['message'],
      read: json['read'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Message {
  final int id;
  final String content;
  final int senderId;
  final int receiverId;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Conversation {
  final User user;
  final String lastMessage;
  final DateTime timestamp;

  Conversation({
    required this.user,
    required this.lastMessage,
    required this.timestamp,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      user: User.fromJson(json['user']),
      lastMessage: json['lastMessage'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
