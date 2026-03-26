import 'package:flutter/material.dart';
import 'package:mugut_gelsin/providers/favorite_provider.dart';
import 'package:provider/provider.dart'; // Paket burada
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugut_gelsin/pages/main_screen.dart';
import 'package:mugut_gelsin/providers/address_provider.dart'; // âœ… Bunu ekle
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
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => OrderTrackingProvider()),
      ],
      child: const mugutGelsinApp(),
    ),
  );
}

class mugutGelsinApp extends StatelessWidget {
  const mugutGelsinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'mugut Gelsin',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    
    // Auth durumu henÃ¼z yÃ¼klenmediyse SplashScreen (Loading) gÃ¶ster
    if (!authProvider.isInitialized) {
      return const SplashScreen();
    }

    // KullanÄ±cÄ± giriÅŸ yapmÄ±ÅŸsa ana sayfa, yapmamÄ±ÅŸsa giriÅŸ sayfasÄ±
    if (authProvider.isLoggedIn) {
      return const MainScreen();
    } else {
      return const LoginPage();
    }
  }
}

