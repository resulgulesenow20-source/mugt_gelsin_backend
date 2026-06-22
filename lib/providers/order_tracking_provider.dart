import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mugut_gelsin/models/order_model.dart';

class OrderTrackingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<OrderModel?> trackOrder(String orderId) {
    return _firestore
        .collection('Emirler')
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return OrderModel.fromFirestore(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  // Active orders for a user
  Stream<List<OrderModel>> getActiveOrders(String uid) {
    return _firestore
        .collection('Emirler')
        .where('customerUid', isEqualTo: uid)
        .where('status', whereIn: ['pending', 'hazırlanıyor', 'yolda', 'onaylanıyor', 'on_the_way'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<bool> submitReview({
    required OrderModel order,
    required String userId,
    required String userName,
    required double rating,
    required double tasteRating,
    required double speedRating,
    required double serviceRating,
    required String comment,
    required List<String> tags,
  }) async {
    try {
      final itemsMap = order.items.map((item) => {
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
        'imageUrl': item.imageUrl,
      }).toList();

      final reviewData = {
        'orderId': order.id,
        'shopId': order.shopId,
        'shop_id': order.shopId,
        'shopName': order.shopName,
        'restaurantId': order.shopId,
        'userId': userId,
        'userName': userName,
        'customerName': userName,
        'rating': rating,
        'tasteRating': tasteRating,
        'speedRating': speedRating,
        'serviceRating': serviceRating,
        'comment': comment,
        'tags': tags,
        'orderedItems': itemsMap,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('Yorumlar').add(reviewData);
      await _firestore.collection('Reviews').add(reviewData);

      await _firestore.collection('Emirler').doc(order.id).update({
        'isRated': true,
      });
      return true;
    } catch (e) {
      debugPrint("Yorum kaydetme hatası: $e");
      return false;
    }
  }
}

