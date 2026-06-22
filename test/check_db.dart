import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

void main() {
  test('Check DB', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('--- CHECKING DUKKANLAR ---');
    final snap = await FirebaseFirestore.instance.collection('Dukkanlar').get();
    print('Dukkanlar count: ${snap.docs.length}');
    for (var doc in snap.docs) {
      print('Dukkan Doc ID: "${doc.id}" -> Name: "${doc.data()['restaurantName'] ?? doc.data()['name']}", Phone: "${doc.data()['phone']}", MugutId: "${doc.data()['mugut_id']}"');
    }

    print('--- CHECKING KAMPANYALAR ---');
    final snap2 = await FirebaseFirestore.instance.collection('Kampanyalar').get();
    print('Kampanyalar count: ${snap2.docs.length}');
    for (var doc in snap2.docs) {
      print('Kampanya Doc ID: "${doc.id}" -> Title: "${doc.data()['title']}", ShopId: "${doc.data()['shop_id']}", IsActive: ${doc.data()['isActive']}');
    }
  });
}
