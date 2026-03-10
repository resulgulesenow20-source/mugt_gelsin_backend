import 'package:flutter/material.dart';
import 'home/home_page.dart';
import 'package:mugt_gelsin/pages/cart/cart_page.dart';
import 'profile/profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // ✅ TEK BİR LİSTE: Diğer iki listeyi sildik, sadece bu kaldı.
  final List<Widget> _pages = [
    const HomePage(), // 0. İndeks: Ana Sayfa
    const CartPage(), // 1. İndeks: Sepetim
    const ProfilePage(), // 2. İndeks: Profil Sayfamız
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Seçili sayfayı sayfalar listesinden çekip gösterir
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF5D3EBD), // Mugt Gelsin Moru
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Sepetim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
