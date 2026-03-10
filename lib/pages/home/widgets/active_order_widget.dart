import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mugt_gelsin/pages/order/order_tracking_page.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';

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
          .where('status', whereIn: ['hazırlanıyor', 'yolda', 'yola çıktı', 'onay bekliyor'])
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
        final docs = snapshot.data!.docs;
        docs.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['timestamp'];
          final bTime = (b.data() as Map<String, dynamic>)['timestamp'];
          if (aTime == null || bTime == null) return 0;
          return bTime.toString().compareTo(aTime.toString());
        });

        final orderDoc = docs.first;
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final String status = orderData['status'] ?? 'hazırlanıyor';
        final String shopName = orderData['shop_name'] ?? 'Restoran';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Siparişini Takip Et",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.textPrimary.withOpacity(0.2)),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getStatusText(status),
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
        icon = Icons.access_time;
        color = AppColors.textPrimary;
        break;
      case 'hazırlanıyor':
        icon = Icons.restaurant;
        color = AppColors.textPrimary;
        break;
      case 'yolda':
      case 'yola çıktı':
        icon = Icons.delivery_dining;
        color = Colors.blue;
        break;
      default:
        icon = Icons.shopping_bag;
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
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
        return "Siparişiniz işleniyor";
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'yolda':
      case 'yola çıktı':
        return Colors.blue;
      case 'onay bekliyor':
        return AppColors.textPrimary;
      default:
        return AppColors.textPrimary;
    }
  }
}
