import 'package:flutter/material.dart';
import 'my_addresses_page.dart'; // ✅ Adreslerim sayfasını import et
// import '../favorites/favorites_page.dart'; // ✅ Eğer favoriler sayfası buradaysa import et

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          "Profilim",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 30),

            // ✅ MENÜ LİSTESİ - BAĞLANTILAR EKLENDİ
            _buildProfileMenuItem(
              Icons.shopping_bag_outlined,
              "Siparişlerim",
              () {
                print("Siparişlerim tıklandı");
                // Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage()));
              },
            ),
            _buildProfileMenuItem(Icons.location_on_outlined, "Adreslerim", () {
              // ✅ ADRESLERİM SAYFASINA GİDİŞ
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyAddressesPage(),
                ),
              );
            }),
            _buildProfileMenuItem(Icons.favorite_border, "Favorilerim", () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesPage()));
            }),
            _buildProfileMenuItem(
              Icons.payment_outlined,
              "Ödeme Yöntemlerim",
              () {
                print("Ödeme yöntemleri tıklandı");
              },
            ),
            _buildProfileMenuItem(
              Icons.card_giftcard_outlined,
              "Kuponlarım",
              () {
                print("Kuponlar tıklandı");
              },
            ),
            _buildProfileMenuItem(Icons.help_outline, "Yardım & Destek", () {
              print("Destek tıklandı");
            }),

            const SizedBox(height: 20),

            _buildProfileMenuItem(Icons.logout, "Çıkış Yap", () {
              _showLogoutDialog(context); // Çıkış için onay kutusu gösterelim
            }, isLogout: true),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ✅ ÇIKIŞ ONAY KUTUSU
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text(
          "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              // Çıkış işlemleri buraya
              Navigator.pop(context);
            },
            child: const Text("Çıkış Yap", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF5D3EBD),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFF7D102),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 20, color: Color(0xFF5D3EBD)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "Kullanıcı Adı",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text("kullanici@mail.com", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : const Color(0xFF5D3EBD),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black,
          ),
        ),
        trailing: isLogout
            ? null
            : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
