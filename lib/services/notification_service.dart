import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Arka planda mesaj gelince tetiklenir
  debugPrint("Arka planda bildirim geldi: ${message.messageId}");
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Bildirim izni verildi.');

      // Eğer kullanıcı giriş yapmışsa token'ı hemen kaydet
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await saveTokenToDatabase(user.uid);
      }

      try {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      } catch (e) {
        debugPrint("Background message handler hatası: $e");
      }

      // Ön plandayken bildirim dinleme
      try {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Ön planda bildirim geldi: ${message.notification?.title}');
        });
      } catch (e) {
        debugPrint("OnMessage listen hatası: $e");
      }
    } else {
      debugPrint('Bildirim izni verilmedi.');
    }
    } catch (e) {
      debugPrint("Initialize hatası: $e");
    }
  }

  static Future<void> saveTokenToDatabase(String uid) async {
    try {
      String? token = await _messaging.getToken(
        // vapidKey: "FIREBASE_CONSOLE_DAN_ALINAN_VAPID_KEY", // Eğer hata verirse buraya VAPID anahtarı girmek gerekebilir.
      );
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
        debugPrint("FCM Token kaydedildi: $token");
      }

      // Token güncellemelerini dinle
      _messaging.onTokenRefresh.listen((newToken) {
        FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fcmToken': newToken,
        }, SetOptions(merge: true));
      });
    } catch (e) {
      debugPrint("Token kaydetme hatası: $e");
    }
  }
}
