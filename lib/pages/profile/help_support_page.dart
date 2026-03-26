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
        title: const Text("YardÄ±m & Destek", style: TextStyle(fontWeight: FontWeight.bold)),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bize UlaÅŸÄ±n",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.support_agent_outlined,
            title: "CanlÄ± Destek",
            subtitle: "MÃ¼ÅŸteri temsilcisi ile hemen gÃ¶rÃ¼ÅŸÃ¼n",
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
            title: "WhatsApp Destek HattÄ±",
            subtitle: "AnÄ±nda Ã§Ã¶zÃ¼m iÃ§in bize yazÄ±n",
            color: Colors.green,
            onTap: () {
              // WhatsApp yÃ¶nlendirmesi eklenebilir
            },
          ),
          const Divider(),
          _buildContactItem(
            icon: Icons.phone_in_talk_outlined,
            title: "MÃ¼ÅŸteri Hizmetlerini Ara",
            subtitle: "Hafta iÃ§i 09:00 - 18:00",
            color: Colors.blue,
            onTap: () {
              // Arama yÃ¶nlendirmesi eklenebilir
            },
          ),
          const Divider(),
          _buildContactItem(
            icon: Icons.mail_outline,
            title: "E-posta GÃ¶nder",
            subtitle: "destek@mugutgelsin.com",
            color: AppColors.textPrimary,
            onTap: () {
              // Mail yÃ¶nlendirmesi eklenebilir
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
          color: color.withValues(alpha: 0.1),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "SÄ±kÃ§a Sorulan Sorular",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          _buildFAQItem("SipariÅŸim ne zaman gelir?", "SipariÅŸleriniz dÃ¼kkanÄ±n yoÄŸunluÄŸuna gÃ¶re ortalama 30-45 dakika iÃ§erisinde teslim edilir."),
          const Divider(height: 1),
          _buildFAQItem("Ã–deme yÃ¶ntemleri nelerdir?", "Åžu an iÃ§in kapÄ±da nakit veya kredi kartÄ± ile Ã¶deme yapabilirsiniz."),
          const Divider(height: 1),
          _buildFAQItem("SipariÅŸi nasÄ±l iptal ederim?", "SipariÅŸiniz hazÄ±rlanmaya baÅŸlamadan Ã¶nce 'YardÄ±m' hattÄ± Ã¼zerinden ulaÅŸarak iptal edebilirsiniz."),
          const Divider(height: 1),
          _buildFAQItem("Adresimi nasÄ±l deÄŸiÅŸtiririm?", "Profil sekmesindeki 'Adreslerim' bÃ¶lÃ¼mÃ¼nden yeni adres ekleyebilir veya dÃ¼zenleyebilirsiniz."),
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

