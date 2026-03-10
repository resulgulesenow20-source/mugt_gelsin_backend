import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_model.dart';

class PaymentProvider with ChangeNotifier {
  final List<PaymentCard> _cards = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<PaymentCard> get cards => _cards;

  // Kullanıcının kartlarını Firestore'dan çek
  Future<void> fetchCards() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .get();

      _cards.clear();
      for (var doc in snapshot.docs) {
        _cards.add(PaymentCard.fromMap(doc.data()));
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Kart çekme hatası: $e");
    }
  }

  Future<void> addCard(PaymentCard card) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Eğer bu ilk kart ise varsayılan yap
      if (_cards.isEmpty) {
        card.isDefault = true;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .doc(card.id)
          .set(card.toMap());

      _cards.add(card);
      notifyListeners();
    } catch (e) {
      debugPrint("Kart ekleme hatası: $e");
    }
  }

  Future<void> deleteCard(String cardId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      bool wasDefault = false;
      int indexToDelete = _cards.indexWhere((c) => c.id == cardId);
      if (indexToDelete != -1) {
        wasDefault = _cards[indexToDelete].isDefault;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .doc(cardId)
          .delete();

      _cards.removeWhere((c) => c.id == cardId);

      // Eğer silinen kart varsayılansa ve başka kart varsa, ilkini varsayılan yap
      if (wasDefault && _cards.isNotEmpty) {
        await setDefaultCard(_cards.first.id);
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Kart silme hatası: $e");
    }
  }

  Future<void> setDefaultCard(String cardId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      WriteBatch batch = _firestore.batch();
      
      for (var card in _cards) {
        DocumentReference ref = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cards')
            .doc(card.id);
        
        if (card.id == cardId) {
          batch.update(ref, {'isDefault': true});
          card.isDefault = true;
        } else {
          batch.update(ref, {'isDefault': false});
          card.isDefault = false;
        }
      }

      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint("Varsayılan kart ayarlama hatası: $e");
    }
  }
}
