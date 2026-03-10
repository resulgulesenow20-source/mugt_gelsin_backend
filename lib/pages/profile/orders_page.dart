import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mugt_gelsin/pages/order/add_review_page.dart';
import 'package:mugt_gelsin/pages/orders/order_tracking_page.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'onaylanıyor':
      case 'hazırlanıyor':
        return AppColors.textPrimary;
      case 'yolda':
        return Colors.blue;
      case 'teslim edildi':
        return Colors.green;
      case 'iletilemedi':
      case 'iptal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Siparişlerim"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(child: Text("Siparişlerinizi görmek için lütfen giriş yapın."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Emirler')
                  .where('customerUid', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Hata oluştu: ${snapshot.error}"),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          "Henüz siparişiniz bulunmamaktadır",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // In-memory sorting to avoid composite index requirement
                final orders = snapshot.data!.docs.toList();
                orders.sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime); // Descending
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index].data() as Map<String, dynamic>;
                    final status = order['status'] ?? 'Bilinmiyor';
                    final price = order['totalPrice']?.toString() ?? '0';
                    final itemsSummary = order['itemsSummary'] ?? '';
                    final timestamp = order['timestamp'] as Timestamp?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(timestamp),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Sipariş Özeti:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              itemsSummary,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Toplam Tutar",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "$price TL",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            // Rating Button
                            if (status.toLowerCase() == 'delivered' || 
                                status.toLowerCase() == 'tamamlandı' || 
                                status.toLowerCase() == 'teslim edildi') ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: order['isRated'] == true 
                                    ? null 
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddReviewPage(
                                              orderId: orders[index].id,
                                              restaurantId: order['shop_id'] ?? 'unknown',
                                              restaurantName: order['shop_name'] ?? 'Restoran',
                                            ),
                                          ),
                                        );
                                      },
                                  icon: Icon(
                                    order['isRated'] == true ? Icons.check_circle_outline : Icons.star_outline,
                                    size: 18,
                                  ),
                                  label: Text(
                                    order['isRated'] == true ? "Değerlendirildi" : "Siparişi Değerlendir",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: order['isRated'] == true ? Colors.grey : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                            // Live Tracking Button for Active Orders
                            if (status.toLowerCase() != 'delivered' && 
                                status.toLowerCase() != 'tamamlandı' && 
                                status.toLowerCase() != 'teslim edildi' &&
                                status.toLowerCase() != 'iptal' &&
                                status.toLowerCase() != 'iletilemedi') ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderTrackingPage(
                                          orderId: orders[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.location_searching_rounded, size: 18),
                                  label: const Text("Siparişi Takip Et", style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
