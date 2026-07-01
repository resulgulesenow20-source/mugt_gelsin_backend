import 'package:cloud_firestore/cloud_firestore.dart';

class TopCategory {
  final String id;
  final String title;
  final String imageUrl;
  final String targetCategory;
  final int order;
  final bool isActive;

  TopCategory({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.targetCategory,
    required this.order,
    required this.isActive,
  });

  factory TopCategory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TopCategory(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['image_url'] ?? '',
      targetCategory: data['target_category'] ?? '',
      order: data['order'] ?? 99,
      isActive: data['is_active'] ?? true,
    );
  }
}
