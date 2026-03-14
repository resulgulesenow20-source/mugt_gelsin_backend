import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../models/payment_model.dart';
import 'add_card_page.dart';
import '../../core/constants/app_colors.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    await Provider.of<PaymentProvider>(context, listen: false).fetchCards();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ödeme Yöntemlerim"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddCardPage()),
            ),
            tooltip: "Yeni Kart Ekle",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : paymentProvider.cards.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 150),
                  itemCount: paymentProvider.cards.length,
                  itemBuilder: (context, index) {
                    final card = paymentProvider.cards[index];
                    return _buildCardItem(context, card, paymentProvider);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Henüz kayıtlı bir kartınız yok",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, PaymentCard card, PaymentProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.contactless_outlined, color: AppColors.textSecondary, size: 30),
                    Text(
                      card.cardType.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  card.cardNumber,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("KART SAHİBİ", style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        Text(
                          card.cardHolder.toUpperCase(),
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("VALID THRU", style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        Text(card.expiryDate, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog(context, card, provider);
                } else if (value == 'default') {
                  provider.setDefaultCard(card.id);
                }
              },
              itemBuilder: (context) => [
                if (!card.isDefault)
                  const PopupMenuItem(value: 'default', child: Text("Varsayılan Yap")),
                const PopupMenuItem(value: 'delete', child: Text("Kartı Sil")),
              ],
            ),
          ),
          if (card.isDefault)
            const Positioned(
              top: 10,
              left: 50,
              child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PaymentCard card, PaymentProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kartı Sil"),
        content: const Text("Bu kartı ödeme yöntemlerinizden silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL")),
          TextButton(
            onPressed: () {
              provider.deleteCard(card.id);
              Navigator.pop(context);
            },
            child: const Text("SİL", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
