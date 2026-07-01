import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';

class Campaign {
  final String id;
  final String shopId;
  final String title;
  final String description;
  final String type; // 'percentage', 'fixed', 'coupon'
  final double value;
  final String? code;
  final double minAmount;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? imageUrl; // ✅ Görsel URL desteği

  Campaign({
    required this.id,
    required this.shopId,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.code,
    required this.minAmount,
    required this.isActive,
    this.startDate,
    this.endDate,
    this.imageUrl,
  });

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String? rawImageUrl = data['imageUrl'] ?? data['image_url'] ?? data['Resim'];
    if (rawImageUrl != null && rawImageUrl.startsWith('static/')) {
      rawImageUrl = '${ApiService.baseUrl}/$rawImageUrl';
    }
    return Campaign(
      id: doc.id,
      shopId: data['shop_id'] ?? data['shopId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'percentage',
      value: double.tryParse(data['value']?.toString() ?? '') ?? 0.0,
      code: data['code'],
      minAmount: double.tryParse(data['minAmount']?.toString() ?? '') ?? 0.0,
      isActive: data['isActive'] ?? true,
      startDate: data['startDate'] is Timestamp ? (data['startDate'] as Timestamp).toDate() : null,
      endDate: data['endDate'] is Timestamp ? (data['endDate'] as Timestamp).toDate() : null,
      imageUrl: rawImageUrl,
    );
  }
}
