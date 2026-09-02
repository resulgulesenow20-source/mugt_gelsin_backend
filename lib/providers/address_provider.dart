import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/address_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressProvider with ChangeNotifier {
  final List<Address> _addresses = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AddressProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchAddresses();
      } else {
        _addresses.clear();
        notifyListeners();
      }
    });
  }

  List<Address> get addresses => _addresses;

  Address? get defaultAddress {
    try {
      if (_addresses.isEmpty) return null;
      return _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first);
    } catch (_) {
      return null;
    }
  }

  // Kullanıcının adreslerini Firestore'dan çek
  Future<void> fetchAddresses() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("FETCH: Kullanıcı oturumu açık değil.");
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .get()
          .timeout(const Duration(seconds: 10));

      _addresses.clear();
      for (final doc in snapshot.docs) {
        _addresses.add(Address.fromMap(doc.data()));
      }
      notifyListeners();
      debugPrint("FETCH: ${_addresses.length} adet adres başarıyla getirildi.");
    } catch (e) {
      debugPrint("FETCH HATASI: $e");
    }
  }

  Future<void> addAddress(Address address) async {
    final user = _auth.currentUser;
    if (user == null) throw "Oturum açık değil.";

    try {
      debugPrint("ADD: Tekli yazma denemesi başlıyor... Path: users/${user.uid}/addresses/${address.id}");
      
      // İlk adresi varsayılan yap
      if (_addresses.isEmpty) {
        address.isDefault = true;
      }

      // DOĞRUDAN VE YALIN YAZMA
      // Metadata (lastUpdate vb) işlemlerini eledik, zaman aşımını kaldırdık ki gerçek hatayı görelim.
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(address.id)
          .set(address.toMap())
          .timeout(const Duration(seconds: 15));

      // Başarılı olursa listeyi güncelle
      if (!_addresses.any((a) => a.id == address.id)) {
        _addresses.add(address);
      }
      notifyListeners();
      debugPrint("ADD: Başarıyla kaydedildi.");
    } on FirebaseException catch (fe) {
      debugPrint("ADD FIREBASE HATASI [${fe.code}]: ${fe.message}");
      throw "Firebase Hatası: ${fe.message}";
    } catch (e) {
      debugPrint("ADD GENEL HATA: $e");
      throw "Bilinmeyen bir hata oluştu: $e";
    }
  }

  Future<void> updateAddress(String oldId, Address newAddress) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(oldId)
          .update(newAddress.toMap());

      int index = _addresses.indexWhere((a) => a.id == oldId);
      if (index != -1) {
        _addresses[index] = newAddress;
        notifyListeners();
      }
      debugPrint("UPDATE: Adres güncellendi.");
    } catch (e) {
      debugPrint("UPDATE HATASI: $e");
      throw "Adres güncellenemedi: $e";
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final batch = _firestore.batch();
      
      for (final addr in _addresses) {
        final ref = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .doc(addr.id);
        
        bool newVal = (addr.id == addressId);
        // update yerine set(merge: true) kullanarak doküman henüz tam oluşmamışsa bile hata almasını önlüyoruz
        batch.set(ref, {'isDefault': newVal}, SetOptions(merge: true));
        addr.isDefault = newVal;
      }

      await batch.commit().timeout(const Duration(seconds: 10));
      notifyListeners();
      debugPrint("DEFAULT: Varsayılan adres değiştirildi -> $addressId");
    } catch (e) {
      debugPrint("DEFAULT HATASI: $e");
    }
  }

  Future<void> deleteAddress(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(id)
          .delete();

      _addresses.removeWhere((a) => a.id == id);
      notifyListeners();
      debugPrint("DELETE: Adres silindi.");
    } catch (e) {
      debugPrint("DELETE HATASI: $e");
    }
  }
}
