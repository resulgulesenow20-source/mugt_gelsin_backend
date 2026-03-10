import 'package:flutter/material.dart';
import 'package:mugt_gelsin/pages/profile/my_addresses_page.dart';
import 'package:mugt_gelsin/pages/profile/help_support_page.dart';
import 'package:mugt_gelsin/pages/profile/orders_page.dart';
import 'package:mugt_gelsin/pages/profile/live_support_page.dart';
import 'package:mugt_gelsin/pages/profile/coupons_page.dart';
import 'package:mugt_gelsin/pages/profile/widgets/profile_header.dart';
import 'package:mugt_gelsin/pages/profile/widgets/profile_menu_item.dart';
import 'package:mugt_gelsin/pages/auth/login_page.dart';
import 'package:mugt_gelsin/presentation/common/dialogs/confirmation_dialog.dart';
import 'package:mugt_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugt_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'payment_methods_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(
          langProvider.translate('nav_profile'),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
            const ProfileHeader(),
            const SizedBox(height: 30),

            ProfileMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: langProvider.translate('orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersPage()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.location_on_outlined,
              title: langProvider.translate('addresses'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAddressesPage(),
                  ),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.payment_outlined,
              title: langProvider.translate('payment_methods'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentMethodsPage()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.card_giftcard_outlined,
              title: langProvider.translate('coupons'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CouponsPage()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: langProvider.translate('help_support'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpSupportPage()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.support_agent,
              title: langProvider.translate('mugt_support'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LiveSupportPage()),
                );
              },
            ),

            const SizedBox(height: 20),

            ProfileMenuItem(
              icon: Icons.logout,
              title: langProvider.translate('logout'),
              isLogout: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => ConfirmationDialog(
                    title: langProvider.translate('logout_confirm_title'),
                    content: langProvider.translate('logout_confirm_desc'),
                    confirmText: langProvider.translate('logout'),
                    onConfirm: () async {
                      await Provider.of<app_auth.AuthProvider>(context, listen: false).signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}
