import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mugut_gelsin/pages/orders/order_tracking_page.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';

class ActiveOrderWidget extends StatelessWidget {
  const ActiveOrderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Emirler')
          .where('customerUid', isEqualTo: user.uid)
          .where('status', whereIn: ['hazırlanıyor', 'yolda', 'yola çıktı', 'onay bekliyor', 'onaylanıyor'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("ActiveOrderWidget Error: ${snapshot.error}");
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          debugPrint("ActiveOrderWidget: Aktif sipariş bulunamadı (Uid: ${user.uid})");
          return const SizedBox.shrink();
        }

        // Bellekte tarihe göre sıralayalım (orderBy index gerektirdiği için kaldırdık)
        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['timestamp'];
          final bTime = (b.data() as Map<String, dynamic>)['timestamp'];
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return -1;
          if (bTime == null) return 1;
          return bTime.toString().compareTo(aTime.toString());
        });

        final orderDoc = docs.first;
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final String status = orderData['status'] ?? 'hazırlanıyor';
        final String shopName = orderData['shop_name'] ?? 'Restoran';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                "Track Your Order",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderTrackingPage(orderId: orderDoc.id),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1.5),
                ),
                child: Row(
                  children: [
                    _buildStatusIcon(status),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shopName,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              letterSpacing: 0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStatusText(status),
                            style: GoogleFonts.outfit(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;

    switch (status.toLowerCase()) {
      case 'onay bekliyor':
        icon = Icons.access_time_rounded;
        color = AppColors.warning;
        break;
      case 'hazırlanıyor':
        icon = Icons.restaurant_rounded;
        color = AppColors.primary;
        break;
      case 'yolda':
      case 'yola çıktı':
        icon = Icons.delivery_dining_rounded;
        color = Colors.blueAccent;
        break;
      default:
        icon = Icons.shopping_bag_rounded;
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'onay bekliyor':
        return "Sipariş onay bekliyor...";
      case 'hazırlanıyor':
        return "Siparişiniz hazırlanıyor...";
      case 'yolda':
      case 'yola çıktı':
        return "Kurye yola çıktı!";
      default:
        return "SipariÅŸiniz iÅŸleniyor";
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'yolda':
      case 'yola çıktı':
        return Colors.blueAccent;
      case 'onay bekliyor':
        return AppColors.warning;
      case 'hazırlanıyor':
        return AppColors.primary;
      default:
        return AppColors.textPrimary;
    }
  }
}

