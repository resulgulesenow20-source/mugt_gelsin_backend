import 'package:flutter/material.dart';
import 'package:mugut_gelsin/pages/profile/my_addresses_page.dart';
import 'package:mugut_gelsin/pages/profile/help_support_page.dart';
import 'package:mugut_gelsin/pages/profile/orders_page.dart';
import 'package:mugut_gelsin/pages/profile/live_support_page.dart';
import 'package:mugut_gelsin/pages/profile/coupons_page.dart';
import 'package:mugut_gelsin/pages/profile/widgets/profile_header.dart';
import 'package:mugut_gelsin/pages/profile/widgets/profile_menu_item.dart';
import 'package:mugut_gelsin/pages/auth/login_page.dart';
import 'package:mugut_gelsin/presentation/common/dialogs/confirmation_dialog.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'payment_methods_page.dart';

import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/pages/profile/widgets/profile_stats_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    
    // Mock values for now, would ideally come from a real provider
    const double balance = 125.50;
    const int points = 450;
    const int activeOrders = 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          langProvider.translate('nav_profile'),
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Settings page could be added later
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const ProfileHeader(),
            const SizedBox(height: 24),
            
            // Statistics Card
            const ProfileStatsCard(
              balance: balance,
              points: points,
              activeOrders: activeOrders,
            ),
            const SizedBox(height: 24),

            // SECTION: HesabÄ±m
            _buildSectionHeader("HESABIM"),
            ProfileMenuItem(
              icon: Icons.location_on_rounded,
              title: langProvider.translate('addresses'),
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAddressesPage())),
            ),
            ProfileMenuItem(
              icon: Icons.payment_rounded,
              title: langProvider.translate('payment_methods'),
              color: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsPage())),
            ),
            ProfileMenuItem(
              icon: Icons.card_giftcard_rounded,
              title: langProvider.translate('coupons'),
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CouponsPage())),
            ),

            const SizedBox(height: 16),

            // SECTION: Ä°ÅŸlemlerim
            _buildSectionHeader("Ä°ÅžLEMLERÄ°M"),
            ProfileMenuItem(
              icon: Icons.shopping_bag_rounded,
              title: langProvider.translate('orders'),
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersPage())),
            ),

            const SizedBox(height: 16),

            // SECTION: Destek
            _buildSectionHeader("DESTEK & YARDIM"),
            ProfileMenuItem(
              icon: Icons.support_agent_rounded,
              title: langProvider.translate('mugut_support'),
              color: AppColors.primary,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveSupportPage())),
            ),
            ProfileMenuItem(
              icon: Icons.help_outline_rounded,
              title: langProvider.translate('help_support'),
              color: Colors.blueGrey,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportPage())),
            ),

            const SizedBox(height: 24),

            // Logout
            ProfileMenuItem(
              icon: Icons.logout_rounded,
              title: langProvider.translate('logout'),
              isLogout: true,
              onTap: () => _showLogoutDialog(context, langProvider),
            ),
            
            const SizedBox(height: 40),
            Text(
              "v1.0.5",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8, top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, LanguageProvider langProvider) {
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
  }
}

