import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userData;
  final bool _isAutoLoggingIn = false;
  bool _isInitialized = false;
  String? _verificationId;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => _user != null;
  bool get isAutoLoggingIn => _isAutoLoggingIn;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    bool isPrefLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    try {
      // Platformdan bağımsız olarak yerel persistence (kalıcılık) ayarla
      // Bu, uygulamanın kapanıp açılması sırasında oturumun korunmasını sağlar
      await _auth.setPersistence(Persistence.LOCAL);
    } catch (e) {
      debugPrint("Persistence desteklenmiyor veya zaten ayarlı: $e");
    }
    
    // Hızlı başlangıç için mevcut kullanıcıyı kontrol et
    _user = _auth.currentUser;
    
    // Firebase SDK henüz kullanıcıyı yüklememiş olabilir, bu yüzden kısa bir bekleme süresi ekliyoruz
    if (isPrefLoggedIn && _user == null) {
      await Future.delayed(const Duration(milliseconds: 800));
      _user = _auth.currentUser;
    }

    if (_user != null) {
      await _fetchUserData(_user!.uid);
      _isInitialized = true;
      notifyListeners();
    }

    _auth.authStateChanges().listen((User? user) async {
      try {
        _user = user;
        if (user != null) {
          await prefs.setBool('isLoggedIn', true);
          await _fetchUserData(user.uid);
        } else {
          await prefs.setBool('isLoggedIn', false); // Çıkış yapılmışsa flag'i temizle
          _userData = null;
        }
      } catch (e) {
        debugPrint("Auth listener hatası: $e");
      } finally {
        _isInitialized = true;
        notifyListeners();
      }
    });
  }

  // --- REAL PHONE AUTHENTICATION ---

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String code) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Otomatik doğrulama (Android)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? "Doğrulama hatası");
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> signInWithOTP(String smsCode, {String? name}) async {
    if (_verificationId == null) throw "Doğrulama kimliği bulunamadı.";

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    
    // Eğer yeni bir kullanıcı ise veya isim verilmişse Firestore kaydı yap/güncelle
    if (userCredential.additionalUserInfo?.isNewUser == true || name != null) {
      await _saveUserToFirestore(userCredential.user!, name: name);
    }
  }

  Future<void> _saveUserToFirestore(User user, {String? name}) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name ?? 'Kullanıcı',
        'phone': user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active', // Varsayılan durum
      });
    } else if (name != null) {
      await _firestore.collection('users').doc(user.uid).update({'name': name});
    }
  }

  // Kullanıcı verilerini Firestore'dan çek
  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userData = doc.data() as Map<String, dynamic>;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Kullanıcı verisi çekme hatası: $e");
    }
  }

  // Kullanıcı verilerini güncelle
  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (_user == null) return;
    try {
      await _firestore.collection('users').doc(_user!.uid).update(data);
      if (_userData != null) {
        _userData!.addAll(data);
      } else {
        _userData = data;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Kullanıcı verisi güncelleme hatası: $e");
    }
  }

  // Çıkış Yap
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Flag'i kesin olarak temizle
    _userData = null;
    notifyListeners();
  }
}
