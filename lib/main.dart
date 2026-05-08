import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mugut_gelsin/providers/favorite_provider.dart';
import 'package:provider/provider.dart'; // Paket burada
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugut_gelsin/pages/main_screen.dart';
import 'package:mugut_gelsin/providers/address_provider.dart'; // ✅ Bunu ekle
import 'package:mugut_gelsin/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mugut_gelsin/pages/auth/login_page.dart';
import 'package:mugut_gelsin/providers/payment_provider.dart';
import 'package:mugut_gelsin/providers/coupon_provider.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/pages/splash/splash_screen.dart';
import 'package:mugut_gelsin/providers/order_tracking_provider.dart';
import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider(scaffoldMessengerKey)),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => OrderTrackingProvider()),
      ],
      child: const MugutGelsinApp(),
    ),
  );
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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    // AuthProvider'ı dinliyoruz
    final authProvider = context.watch<app_auth.AuthProvider>();

    // Eğer sistem henüz Firebase'in başlama sürecini bitirmediyse Splash göster
    if (!authProvider.isInitialized) {
      return const SplashScreen();
    }

    // Kullanıcı giriş yapmışsa (Firebase User doluysa)
    if (authProvider.isLoggedIn) {
      return const MainScreen();
    }

    // Eğer AuthProvider henüz 'null' diyorsa ama SharedPreferences'a göre giriş yapıldıysa
    // bu Web platformundaki IndexedDB gecikmesidir; yükleme ekranı göstererek Stream'in güncellenmesini bekle.
    if (authProvider.hasPersistedLogin) {
      return const SplashScreen(); 
    }

    // Aksi halde giriş ekranına gönder
    return const LoginPage();
  }
}

