import 'package:flutter/material.dart';
import 'package:mugt_gelsin/providers/favorite_provider.dart';
import 'package:provider/provider.dart'; // Paket burada
import 'package:mugt_gelsin/providers/cart_provider.dart';
import 'package:mugt_gelsin/providers/auth_provider.dart';
import 'package:mugt_gelsin/pages/main_screen.dart';
import 'package:mugt_gelsin/providers/address_provider.dart'; // ✅ Bunu ekle

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: const MugtGelsinApp(),
    ),
  );
}

class MugtGelsinApp extends StatelessWidget {
  const MugtGelsinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF5D3EBD),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5D3EBD)),
        useMaterial3: true, // Daha modern bir görünüm sağlar
      ),
      // ✅ HATA BURADAYDI: Uygulama açıldığında hangi sayfa görünecek?
      home: const MainScreen(),
    );
  }
}
