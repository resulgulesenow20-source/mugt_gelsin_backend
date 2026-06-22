import 'dart:async';
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
  bool _hasPersistedLogin = false; // WEB İÇİN GECİKME ÖNLEYİCİ
  String? _verificationId;
  final GlobalKey<ScaffoldMessengerState>? _messengerKey;
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => _user != null;
  bool get isAutoLoggingIn => _isAutoLoggingIn;
  bool get isInitialized => _isInitialized;
  bool get hasPersistedLogin => _hasPersistedLogin;

  AuthProvider([this._messengerKey]) {
    _init();
  }

  void _listenToUserData(String uid) {
    _userDataSubscription?.cancel();
    _userDataSubscription = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _userData = doc.data();
        notifyListeners();
      }
    }, onError: (error) {
      debugPrint("Kullanıcı verisi dinleme hatası: $error");
    });
  }

  void _cancelUserDataSubscription() {
    _userDataSubscription?.cancel();
    _userDataSubscription = null;
  }

  Future<void> _init() async {
    // 0. Hızlıca yerel hafızaya bak, eğer daha önce giriş yaptıysa anında flag'i true yap
    final prefs = await SharedPreferences.getInstance();
    _hasPersistedLogin = prefs.getBool('isLoggedIn') ?? false;

    try {
      // Platformdan bağımsız olarak yerel persistence (kalıcılık) ayarla
      await _auth.setPersistence(Persistence.LOCAL);
    } catch (e) {
      debugPrint("Persistence desteklenmiyor veya zaten ayarlı: $e");
    }
    
    // 1. Durum değişikliklerini sürekli dinle
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user == null) {
        _userData = null;
        _cancelUserDataSubscription();
      } else {
        prefs.setBool('isLoggedIn', true); // Giriş yapmışsa hemen true olarak kaydet
        _hasPersistedLogin = true;
        _listenToUserData(user.uid);
      }
      
      // Eğer sistem zaten başlatılıp UI'a haber verildiyse, yeni değişiklikleri bildir
      if (_isInitialized) {
        notifyListeners();
      }
    });

    // 2. İlk açılışta Firebase'in oturumu geri yüklemesini tamamen bekle
    debugPrint("Auth Service: Firebase başlangıç durumu bekleniyor...");
    
    // Web üzerinde oturumun geri gelmesi için biraz vakit vermek gerekebilir
    // Sadece .first yerine stream'i bir süre dinleyip geçerli bir user gelmesini beklemek daha sağlıklı olabilir.
    _user = _auth.currentUser;
    if (_user == null) {
      // Bir kez daha bekle (Web için kritik)
      await Future.delayed(const Duration(milliseconds: 500));
      _user = _auth.currentUser;
    }

    debugPrint("Auth Service: Başlangıç durumu alındı. Kullanıcı: ${_user?.uid ?? 'Yok'}");

    if (_user != null) {
      prefs.setBool('isLoggedIn', true);
      _hasPersistedLogin = true;
      // Kullanıcı verilerini ÇEK ve BEKLE (UI açılmadan verilerin hazır olması önemli)
      await _fetchUserData(_user!.uid);
      _saveUserToFirestore(_user!); // Arkada çalışsın, UI'ı bloklamasın
    } else {
      // Eğer user gerçekten yoksa, login flag'ini kesin olarak temizle
      _hasPersistedLogin = false;
      await prefs.setBool('isLoggedIn', false);
    }

    // 3. UI'a uygulamanın hazır olduğunu bildir
    _isInitialized = true;
    notifyListeners();
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
    
    // Giriş başarılı olduktan sonra Firestore kaydını ve veri çekmeyi await edelim.
    // Böylece kullanıcı ana sayfaya yönlendirilmeden önce profil verileri tamamen yüklenmiş olur.
    await _saveUserToFirestore(userCredential.user!, name: name);
    await _fetchUserData(userCredential.user!.uid);
  }

  Future<void> _saveUserToFirestore(User user, {String? name}) async {
    try {
      debugPrint("Auth Service: Firestore'a kullanıcı kaydediliyor/güncelleniyor.");
      
      final userDoc = _firestore.collection('users').doc(user.uid);
      
      // Get the document (but catch timeout so it doesn't break the silent backend task)
      try {
        final doc = await userDoc.get().timeout(const Duration(seconds: 8));
        
        if (!doc.exists) {
          await userDoc.set({
            'name': name ?? 'Kullanıcı',
            'phone': user.phoneNumber ?? '',
            'email': user.email ?? '',
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'active',
            'lastLogin': FieldValue.serverTimestamp(),
            'balance': 0.0,
            'points': 0,
          }).timeout(const Duration(seconds: 3));
        } else {
          Map<String, dynamic> updates = {'lastLogin': FieldValue.serverTimestamp()};
          if (name != null) updates['name'] = name;
          await userDoc.update(updates).timeout(const Duration(seconds: 3));
        }
      } catch (e) {
        // Eğer Get işlemi timeout yemişse (örneğin Emulator kaynaklı gRPC bağlantı sorunu),
        // Mevcut kullanıcının puan/bakiye gibi önemli verilerini sıfırlamamak için 
        // balance ve points alanlarını buradan kaldırıyoruz (sadece merge ile temel alanları güncelliyoruz).
        Map<String, dynamic> offlineData = {
          'phone': user.phoneNumber ?? '',
          'uid': user.uid,
          'lastLogin': FieldValue.serverTimestamp(),
        };
        if (name != null) offlineData['name'] = name;
        await userDoc.set(offlineData, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
      }
    } catch (e) {
      debugPrint("!!!!!!!! FIRESTORE KAYIT HATASI !!!!!!!!: $e");
    }
  }

  void _showError(String message) {
    if (_messengerKey != null && _messengerKey!.currentState != null) {
      _messengerKey!.currentState!.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Kullanıcı verilerini Firestore'dan çek
  Future<void> _fetchUserData(String uid) async {
    try {
      // Ağı beklemek yerine varsa önbellekten de hızlıca alabilmesi için timeout koyuyoruz
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 5));
      if (doc.exists) {
        _userData = doc.data() as Map<String, dynamic>;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Kullanıcı verisi çekme hatası (veya Timeout): $e");
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
    _cancelUserDataSubscription();
    notifyListeners();
  }
}
