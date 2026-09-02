import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Paket burada
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugut_gelsin/pages/main_screen.dart';
import 'package:mugut_gelsin/providers/address_provider.dart'; // ✅ Bunu ekle
import 'package:mugut_gelsin/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mugut_gelsin/pages/auth/login_page.dart';
import 'package:mugut_gelsin/providers/payment_provider.dart';
import 'package:mugut_gelsin/providers/coupon_provider.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/providers/region_provider.dart';
import 'package:mugut_gelsin/pages/splash_page.dart';
import 'package:mugut_gelsin/providers/order_tracking_provider.dart';
import 'package:mugut_gelsin/services/notification_service.dart';
import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Mavi başlıklı tasarım için şeffaf
      statusBarIconBrightness: Brightness.light, // Mavi zemin üzerinde açık ikonlar
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification service
  await NotificationService.initialize();

  // Enable offline persistence and unlimited cache for fast load times on slow internet
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    debugPrint("Firestore offline persistence initialized successfully.");
  } catch (e) {
    debugPrint("Error initializing Firestore persistence: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider(scaffoldMessengerKey)),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => RegionProvider()),
        ChangeNotifierProvider(create: (_) => OrderTrackingProvider()),
      ],
      child: const MugutGelsinApp(),
    ),
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MugutGelsinApp extends StatelessWidget {
  const MugutGelsinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'mugut Gelsin',
      theme: AppTheme.lightTheme,
      scrollBehavior: const AppScrollBehavior(),
      home: const SplashPage(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Uygulama açıldığında direkt ana ekrana geç, kayıt veya giriş sorma
    return const MainScreen();
  }
}

