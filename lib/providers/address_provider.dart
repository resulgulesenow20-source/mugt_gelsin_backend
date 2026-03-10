import 'package:flutter/material.dart';
import 'package:mugt_gelsin/models/address_model.dart';
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

  // Kullanıcının adreslerini Firestore'dan çek
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
      debugPrint("Adres çekme hatası: $e");
    }
  }

  Future<void> addAddress(Address address) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Eğer bu ilk adres ise varsayılan yap
      if (_addresses.isEmpty) {
        address.isDefault = true;
      }

      // Önce Firestore'a ekle
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
      debugPrint("Adres ekleme hatası: $e");
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      WriteBatch batch = _firestore.batch();
      
      // Tüm adreslerin isDefault değerini false yap
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
      debugPrint("Varsayılan adres ayarlama hatası: $e");
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
      debugPrint("Adres güncelleme hatası: $e");
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

      // Eğer silinen adres varsayılansa ve başka adres varsa, ilkini varsayılan yap
      if (wasDefault && _addresses.isNotEmpty) {
        await setDefaultAddress(_addresses.first.id);
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Adres silme hatası: $e");
    }
  }
}
