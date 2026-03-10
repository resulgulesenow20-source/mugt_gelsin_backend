import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mugt_gelsin/models/order_model.dart';

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
}
