import 'package:flutter/material.dart';
import 'package:mugut_gelsin/pages/home/home_page.dart';
import 'package:mugut_gelsin/pages/profile/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'cart/cart_page.dart'; // Bu importu ekle

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 2; // Default to Home (Center FAB)

  // Ekran listesi (5 Sekme)
  final List<Widget> _pages = [
    const Center(child: Text("Fırsatlar & Özet", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))), // 0: Yeni Sol Sekme
    const Center(child: Text("Arama")), // 1: Arama
    const HomePage(), // 2: Merkez (Sipariş Ver / Ana Sayfa)
    const CartPage(), // 3: Sepet
    const ProfilePage(), // 4: Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 75,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.dashboard_outlined, Icons.dashboard, "Fırsatlar", 0),
            _buildNavItem(Icons.search, Icons.search, "Arama", 1),
            _buildCenterItem(),
            _buildCartItem(),
            _buildNavItem(Icons.person_outline, Icons.person, "Profil", 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? Colors.deepPurple : Colors.grey, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.deepPurple : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterItem() {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 2),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700), // Yellow
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.motorcycle, color: Colors.black, size: 28),
          ),
          const SizedBox(height: 4),
          const Text(
            "Sipariş Ver",
            style: TextStyle(fontSize: 10, color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem() {
    final isSelected = _selectedIndex == 3;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 3),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? Icons.shopping_cart : Icons.shopping_cart_outlined, 
                      color: isSelected ? Colors.deepPurple : Colors.grey,
                      size: 26,
                    ),
                    if (cart.items.isNotEmpty)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFF56AA86), shape: BoxShape.circle),
                          child: Text(
                            '${cart.items.fold(0, (sum, item) => sum + item.quantity)}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              "Sepetim",
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.deepPurple : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

