import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/address_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressProvider with ChangeNotifier {
  final List<Address> _addresses = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Address> get addresses => _addresses;

  Address? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  // KullanÄ±cÄ±nÄ±n adreslerini Firestore'dan Ã§ek
  Future<void> fetchAddresses() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .get();

      _addresses.clear();
      for (var doc in snapshot.docs) {
        _addresses.add(Address.fromMap(doc.data()));
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Adres Ã§ekme hatasÄ±: $e");
    }
  }

  Future<void> addAddress(Address address) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // EÄŸer bu ilk adres ise varsayÄ±lan yap
      if (_addresses.isEmpty) {
        address.isDefault = true;
      }

      // Ã–nce Firestore'a ekle
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(address.id)
          .set(address.toMap());

      // Sonra yerel listeye ekle
      _addresses.add(address);
      notifyListeners();
    } catch (e) {
      debugPrint("Adres ekleme hatasÄ±: $e");
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      WriteBatch batch = _firestore.batch();
      
      // TÃ¼m adreslerin isDefault deÄŸerini false yap
      for (var addr in _addresses) {
        DocumentReference ref = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .doc(addr.id);
        
        if (addr.id == addressId) {
          batch.update(ref, {'isDefault': true});
          addr.isDefault = true;
        } else {
          batch.update(ref, {'isDefault': false});
          addr.isDefault = false;
        }
      }

      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint("VarsayÄ±lan adres ayarlama hatasÄ±: $e");
    }
  }

  Future<void> updateAddress(String id, Address newAddress) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(id)
          .update(newAddress.toMap());

      int index = _addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        _addresses[index] = newAddress;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Adres gÃ¼ncelleme hatasÄ±: $e");
    }
  }

  Future<void> deleteAddress(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      bool wasDefault = false;
      int indexToDelete = _addresses.indexWhere((a) => a.id == id);
      if (indexToDelete != -1) {
        wasDefault = _addresses[indexToDelete].isDefault;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(id)
          .delete();

      _addresses.removeWhere((a) => a.id == id);

      // EÄŸer silinen adres varsayÄ±lansa ve baÅŸka adres varsa, ilkini varsayÄ±lan yap
      if (wasDefault && _addresses.isNotEmpty) {
        await setDefaultAddress(_addresses.first.id);
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Adres silme hatasÄ±: $e");
    }
  }
}

