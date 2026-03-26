import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mugut_gelsin/pages/orders/add_review_page.dart';
import 'package:mugut_gelsin/pages/orders/order_tracking_page.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:provider/provider.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'onay bekliyor':
      case 'onaylanÄ±yor':
        return AppColors.textPrimary;
      case 'hazÄ±rlanÄ±yor':
        return AppColors.primary;
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

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'onay bekliyor':
      case 'onaylanÄ±yor':
        icon = Icons.timer_outlined;
        break;
      case 'hazÄ±rlanÄ±yor':
        icon = Icons.restaurant_rounded;
        break;
      case 'yolda':
        icon = Icons.delivery_dining_rounded;
        break;
      case 'teslim edildi':
        icon = Icons.check_circle_rounded;
        break;
      case 'iptal':
      case 'iletilemedi':
        icon = Icons.cancel_rounded;
        break;
      default:
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
  void _reorderItems(BuildContext context, Map<String, dynamic> order) {
    final cart = context.read<CartProvider>();
    final List<dynamic> items = order['items'] ?? [];
    final String shopId = order['shop_id'] ?? '';
    final String shopName = order['shop_name'] ?? '';

    if (items.isEmpty) return;

    // Sepeti temizleyelim mi? KullanÄ±cÄ±ya sorulabilir ama ÅŸimdilik doÄŸrudan ekleyelim
    // EÄŸer farklÄ± bir dÃ¼kkan ise sepet otomatik temizleniyor zaten (CartProvider kuralÄ±)
    
    for (var item in items) {
      final String name = item['name'] ?? 'ÃœrÃ¼n';
      final double price = (item['price'] is int) ? (item['price'] as int).toDouble() : (item['price'] ?? 0.0);
      final int quantity = item['quantity'] ?? 1;

      // Dummy food object created from history
      final food = Food(
        id: name.hashCode.toString(),
        name: name,
        price: price,
        imageUrl: '', // No image in history
        description: '',
      );

      for (int i = 0; i < quantity; i++) {
        cart.addToCart(
          food,
          restaurantId: shopId,
          restaurantName: shopName,
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$shopName sipariÅŸiniz sepete tekrar eklendi!"),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("SipariÅŸlerim"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(child: Text("SipariÅŸlerinizi gÃ¶rmek iÃ§in lÃ¼tfen giriÅŸ yapÄ±n."))
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
                    child: Text("Hata oluÅŸtu: ${snapshot.error}"),
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
                          "HenÃ¼z sipariÅŸiniz bulunmamaktadÄ±r",
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
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return -1;
                  if (bTime == null) return 1;
                  return bTime.compareTo(aTime); // Descending
                });

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 150),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index].data() as Map<String, dynamic>;
                    final status = order['status'] ?? 'Bilinmiyor';
                    final price = order['totalPrice']?.toString() ?? '0';
                    final items = order['items'] as List<dynamic>? ?? [];
                    final shopName = order['shop_name'] ?? 'Bilinmeyen Restoran';
                    final timestamp = order['timestamp'] as Timestamp?;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shop Name Area (Like a field)
                          Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    shopName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatDate(timestamp),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Items List
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "SipariÅŸ Ã–zeti",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    _buildStatusBadge(status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        "${item['quantity']}x",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item['name'] ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                        "${item['price']} TL",
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )),
                                const Divider(height: 32, thickness: 1),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Toplam",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      "$price TL",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Footer Actions
                          Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                            child: Row(
                              children: [
                                if (status.toLowerCase() == 'delivered' || 
                                    status.toLowerCase() == 'tamamlandÄ±' || 
                                    status.toLowerCase() == 'tamamlandi' || 
                                    status.toLowerCase() == 'teslim edildi') ...[
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _reorderItems(context, order),
                                      icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.black),
                                      label: const Text("SipariÅŸi Tekrarla"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: OutlinedButton(
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
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        side: const BorderSide(color: Colors.black),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Text(order['isRated'] == true ? "PuanlandÄ±" : "Puanla"),
                                    ),
                                  ),
                                ],

                                if (status.toLowerCase() != 'delivered' && 
                                    status.toLowerCase() != 'tamamlandÄ±' && 
                                    status.toLowerCase() != 'teslim edildi' &&
                                    status.toLowerCase() != 'iptal' &&
                                    status.toLowerCase() != 'iletilemedi') ...[
                                  Expanded(
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
                                      label: const Text("CanlÄ± Takip Et"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[700],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

