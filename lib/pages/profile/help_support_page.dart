import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';

import 'package:mugut_gelsin/pages/profile/live_support_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("Yardım & Destek", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildContactSection(context),
            const SizedBox(height: 20),
            _buildFAQSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bize Ulaşın",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.support_agent_outlined,
            title: "Canlı Destek",
            subtitle: "Müşteri temsilcisi ile hemen görüşün",
            color: AppColors.textPrimary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LiveSupportPage()),
              );
            },
          ),
          const Divider(),
          _buildContactItem(
            icon: Icons.chat_bubble_outline,
            title: "WhatsApp Destek Hattı",
            subtitle: "Anında çözüm için bize yazın",
            color: Colors.green,
            onTap: () {
              // WhatsApp yönlendirmesi eklenebilir
            },
          ),
          const Divider(),
          _buildContactItem(
            icon: Icons.phone_in_talk_outlined,
            title: "Müşteri Hizmetlerini Ara",
            subtitle: "Hafta içi 09:00 - 18:00",
            color: Colors.blue,
            onTap: () {
              // Arama yönlendirmesi eklenebilir
            },
          ),
          const Divider(),
          _buildContactItem(
            icon: Icons.mail_outline,
            title: "E-posta Gönder",
            subtitle: "destek@mugutgelsin.com",
            color: AppColors.textPrimary,
            onTap: () {
              // Mail yönlendirmesi eklenebilir
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Sıkça Sorulan Sorular",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          _buildFAQItem("Siparişim ne zaman gelir?", "Siparişleriniz dükkanın yoğunluğuna göre ortalama 30-45 dakika içerisinde teslim edilir."),
          const Divider(height: 1),
          _buildFAQItem("Ödeme yöntemleri nelerdir?", "Şu an için kapıda nakit veya kredi kartı ile ödeme yapabilirsiniz."),
          const Divider(height: 1),
          _buildFAQItem("Siparişi nasıl iptal ederim?", "Siparişiniz hazırlanmaya başlamadan önce 'Yardım' hattı üzerinden ulaşarak iptal edebilirsiniz."),
          const Divider(height: 1),
          _buildFAQItem("Adresimi nasıl değiştiririm?", "Profil sekmesindeki 'Adreslerim' bölümünden yeni adres ekleyebilir veya düzenleyebilirsiniz."),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
        ),
      ],
    );
  }
}

