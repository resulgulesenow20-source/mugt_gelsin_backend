import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

void main() {
  test('Check Bolgeler', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('--- CHECKING BOLGELER ---');
    try {
      final snap = await FirebaseFirestore.instance.collection('Bolgeler').get();
      print('Bolgeler count: ${snap.docs.length}');
      for (var doc in snap.docs) {
        print('Bolge Doc ID: "${doc.id}" -> Data: ${doc.data()}');
      }
    } catch(e) {
      print('Bolgeler error: $e');
    }
  });
}
