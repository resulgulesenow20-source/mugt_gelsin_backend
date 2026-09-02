import 'package:flutter/material.dart';
import 'package:mugut_gelsin/pages/profile/my_addresses_page.dart';
import 'package:mugut_gelsin/pages/profile/admin_panel_page.dart';
import 'package:mugut_gelsin/pages/profile/help_support_page.dart';
import 'package:mugut_gelsin/pages/profile/terms_page.dart';
import 'package:mugut_gelsin/pages/profile/widgets/profile_header.dart';
import 'package:mugut_gelsin/pages/main_screen.dart';
import 'package:mugut_gelsin/presentation/common/dialogs/confirmation_dialog.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'payment_methods_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/pages/home/widgets/logo_mark_widget.dart';

class _AppBarLogo extends StatelessWidget {
  const _AppBarLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const LogoMarkWidget(size: 44, color: Color(0xFF6BCC5E)),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mugut",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              "gelsin",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<app_auth.AuthProvider>();
    final userData = authProvider.userData;
    
    final double balance = authProvider.walletBalance > 0 
        ? authProvider.walletBalance 
        : (userData?['balance'] ?? 0.0).toDouble();
    final bool isAdmin = userData?['role'] == 'admin' || userData?['isAdmin'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFF2B0F6B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B0F6B),
        elevation: 0,
        title: const _AppBarLogo(),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF9F7FC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Profilim header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    const Expanded(
                      child: Text(
                        "Profilim",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF130A2A),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {}, // Settings tap
                      child: const Icon(Icons.settings_outlined, color: Color(0xFF130A2A)),
                    ),
                  ],
                ),
              ),
              
              const ProfileHeader(),
              
              // Balance Card
              _buildBalanceCard(balance),
              
              // Settings
              _buildSettingsSection(context, langProvider, isAdmin),
              
              const SizedBox(height: 120), // Bottom padding for navigation bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7FC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Stack(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2B0F6B)),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(Icons.circle, color: Color(0xFFFFD500), size: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Mugt balansy", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF130A2A))),
                    Text("Sargytlarynyzda pe�dalanyn", style: TextStyle(fontFamily: 'Inter', color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD500).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF130A2A)),
                      ),
                      child: const Text("T", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF130A2A))),
                    ),
                    const SizedBox(width: 6),
                    Text("${balance.toInt()} TMT", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF130A2A))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Lines
        Row(
          children: [
            Expanded(child: Container(height: 4, color: const Color(0xFFFFD500))),
            Expanded(child: Container(height: 4, color: const Color(0xFFFFD500))),
            Expanded(child: Container(height: 4, color: const Color(0xFFFFD500))),
            Expanded(child: Container(height: 4, color: Colors.grey.shade200)),
          ],
        ),
        // Nodes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildProgressNode("10", true),
            _buildProgressNode("20", true),
            _buildProgressNode("30", true),
            _buildProgressNode("50", false),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressNode(String text, bool active) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFD500) : Colors.white,
        shape: BoxShape.circle,
        border: active ? null : Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Text(text, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14, color: active ? const Color(0xFF130A2A) : Colors.grey)),
    );
  }

  Widget _buildSettingsSection(BuildContext context, LanguageProvider lang, bool isAdmin) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sazlamalar", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF130A2A))),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuItem(context, Icons.location_on_outlined, "Adreslerim", "�etirilmeli salgylarymy dolandyryn", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAddressesPage()))),
                _buildDivider(),
                _buildMenuItem(context, Icons.credit_card_outlined, "T�leg usullarym", "T�leg kartlarynyzy dolandyryn", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsPage()))),
                _buildDivider(),
                _buildMenuItem(context, Icons.notifications_none_rounded, "Bildirisler", "Sargytlar we kampani�alar hakda", () {}),
                _buildDivider(),
                _buildMenuItem(context, Icons.help_outline_rounded, "K�mek merkezi", "K�mek, soraglar we goldaw", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage()))),
                
                _buildDivider(),
                _buildMenuItem(context, Icons.description_outlined, "Ulanyjy şertnamasy", "Kada we düzgünler", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage()))),
                
                if (isAdmin) ...[
                  _buildDivider(),
                  _buildMenuItem(context, Icons.admin_panel_settings_outlined, "Y�netici Paneli", "Uygulamayi y�net", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelPage()))),
                ],
                _buildDivider(),
                _buildMenuItem(context, Icons.logout_rounded, "�yk", "Hasapdan �ykmak", () => _showLogoutDialog(context, lang), isDestructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(height: 1, color: Colors.grey.shade100, thickness: 1),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red.shade50 : const Color(0xFFF9F7FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF2B0F6B), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15, color: isDestructive ? Colors.red : const Color(0xFF130A2A))),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: const TextStyle(fontFamily: 'Inter', color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
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
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}


