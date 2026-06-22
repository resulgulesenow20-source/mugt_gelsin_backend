import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? id;
  final String? userId;
  final String userName;
  final String? restaurantId;
  final double rating; // General average
  final double tasteRating;
  final double speedRating;
  final double serviceRating;
  final String comment;
  final List<String> tags;
  final DateTime timestamp;
  final String? reply;
  final List<Map<String, dynamic>> orderedItems;

  Review({
    this.id,
    this.userId,
    required this.userName,
    this.restaurantId,
    required this.rating,
    this.tasteRating = 0.0,
    this.speedRating = 0.0,
    this.serviceRating = 0.0,
    required this.comment,
    this.tags = const [],
    required this.timestamp,
    this.reply,
    this.orderedItems = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'restaurantId': restaurantId,
      'rating': rating,
      'tasteRating': tasteRating,
      'speedRating': speedRating,
      'serviceRating': serviceRating,
      'comment': comment,
      'tags': tags,
      'timestamp': FieldValue.serverTimestamp(),
      'reply': reply,
      'orderedItems': orderedItems,
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
      userId: map['userId']?.toString(),
      userName: map['customerName']?.toString() ?? map['userName']?.toString() ?? 'Adsız Kullanıcı',
      restaurantId: map['restaurantId']?.toString(),
      rating: double.tryParse(map['rating']?.toString() ?? '0.0') ?? 0.0,
      tasteRating: double.tryParse(map['tasteRating']?.toString() ?? '0.0') ?? 0.0,
      speedRating: double.tryParse(map['speedRating']?.toString() ?? '0.0') ?? 0.0,
      serviceRating: double.tryParse(map['serviceRating']?.toString() ?? '0.0') ?? 0.0,
      comment: map['comment']?.toString() ?? '',
      tags: map['tags'] is List
          ? (map['tags'] as List).map((e) => e.toString()).toList()
          : const [],
      timestamp: parsedDate,
      reply: map['reply']?.toString(),
      orderedItems: map['orderedItems'] is List
          ? List<Map<String, dynamic>>.from(
              (map['orderedItems'] as List).map((e) => Map<String, dynamic>.from(e as Map)))
          : map['items'] is List
              ? List<Map<String, dynamic>>.from(
                  (map['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)))
              : const [],
    );
  }
}
