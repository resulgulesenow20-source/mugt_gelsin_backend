import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? id;
  final String? userId;
  final String userName;
  final String? restaurantId;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final String? reply;

  Review({
    this.id,
    this.userId,
    required this.userName,
    this.restaurantId,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.reply,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'restaurantId': restaurantId,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
      'reply': reply,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map, [String? documentId]) {
    DateTime parsedDate;
    if (map['date'] != null) {
      try {
        parsedDate = DateTime.parse(map['date'].toString().replaceAll(" ", "T"));
      } catch(e) {
        parsedDate = DateTime.now();
      }
    } else if (map['timestamp'] is Timestamp) {
      parsedDate = (map['timestamp'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return Review(
      id: map['id']?.toString() ?? documentId ?? '',
      userId: map['userId'],
      userName: map['customerName'] ?? map['userName'] ?? 'Adsız Kullanıcı',
      restaurantId: map['restaurantId'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      timestamp: parsedDate,
      reply: map['reply'],
    );
  }
}
