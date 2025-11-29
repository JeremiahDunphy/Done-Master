class User {
  final int id;
  final String email;
  final String name;
  final String role;
  final bool isElite;
  final int jobsCompleted;
  final double averageRating;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isElite = false,
    this.jobsCompleted = 0,
    this.averageRating = 0.0,
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
    );
  }
}

class Job {
  final int id;
  final String title;
  final String description;
  final double price;
  final double latitude;
  final double longitude;
  final String status;
  final List<String> photos;
  final int clientId;
  final int? providerId;
  final String? zipCode;
  final String? category;
  final List<String>? tags;
  final bool isUrgent;
  final User? client;
  final User? provider;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.photos,
    required this.clientId,
    this.providerId,
    this.zipCode,
    this.category,
    this.tags,
    this.isUrgent = false,
    this.client,
    this.provider,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      status: json['status'],
      photos: (json['photos'] != null && json['photos'].toString().isNotEmpty)
          ? json['photos'].toString().split(',')
          : [],
      clientId: json['clientId'],
      providerId: json['providerId'],
      zipCode: json['zipCode'],
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags'].toString().split(',')) : null,
      isUrgent: json['isUrgent'] ?? false,
      client: json['client'] != null ? User.fromJson(json['client']) : null,
      provider: json['provider'] != null ? User.fromJson(json['provider']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'photos': photos.join(','),
      'clientId': clientId,
      'providerId': providerId,
      'zipCode': zipCode,
      'category': category,
      'tags': tags?.join(','),
      'isUrgent': isUrgent,
      // We don't typically serialize full objects back to JSON for API requests, but good for debugging
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
