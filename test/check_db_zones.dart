import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final restaurants = await FirebaseFirestore.instance.collection('Dukkanlar').get();
  final zones = await FirebaseFirestore.instance.collection('Bolgeler').get();

  print("Restaurants:");
  for (var r in restaurants.docs) {
    print("${r.id} - ${r.data()['name']} - phone: ${r.data()['phone']} - mugut_id: ${r.data()['mugut_id']}");
  }

  print("\nZones:");
  for (var z in zones.docs) {
    print("${z.id} - ${z.data()['name']} - shop_id: ${z.data()['shop_id']}");
  }
}
