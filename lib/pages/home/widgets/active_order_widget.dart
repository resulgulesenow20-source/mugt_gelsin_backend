import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mugut_gelsin/pages/orders/order_tracking_page.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';

class ActiveOrderWidget extends StatefulWidget {
  const ActiveOrderWidget({super.key});

  @override
  State<ActiveOrderWidget> createState() => _ActiveOrderWidgetState();
}

class _ActiveOrderWidgetState extends State<ActiveOrderWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Emirler')
          .where('customerUid', isEqualTo: user.uid)
          .where('status', whereIn: ['pending', 'hazÄ±rlanÄ±yor', 'yolda', 'yola Ã§Ä±ktÄ±', 'onay bekliyor', 'onaylanÄ±yor', 'on_the_way'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("ActiveOrderWidget Error: ${snapshot.error}");
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        // âœ… SipariÅŸleri Tarihe GÃ¶re (En Yeni En Ãœstte) SÄ±ralayalÄ±m
        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['timestamp'];
          final bTime = (b.data() as Map<String, dynamic>)['timestamp'];
          
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime); // En yeni en Ã¶nce
          }
          return 0;
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    docs.length > 1 ? "Aktif SipariÅŸlerin (${docs.length})" : "SipariÅŸini Takip Et",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  if (docs.length > 1)
                    Row(
                      children: List.generate(docs.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: _currentPage == index ? 12 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? AppColors.primary : Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ),
            
            SizedBox(
              height: 125, // Sabit yÃ¼kseklik
              child: PageView.builder(
                controller: _pageController,
                itemCount: docs.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final orderDoc = docs[index];
                  final orderData = orderDoc.data() as Map<String, dynamic>;
                  final String status = orderData['status'] ?? 'hazÄ±rlanÄ±yor';
                  final String shopName = orderData['shop_name'] ?? 'Restoran';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTrackingPage(orderId: orderDoc.id),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          _buildStatusIcon(status),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  shopName,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
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
                  );
                },
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
      case 'hazÄ±rlanÄ±yor':
        icon = Icons.restaurant_rounded;
        color = AppColors.primary;
        break;
      case 'yolda':
      case 'yola Ã§Ä±ktÄ±':
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'onay bekliyor':
        return "SipariÅŸ onay bekliyor...";
      case 'hazÄ±rlanÄ±yor':
        return "SipariÅŸiniz hazÄ±rlanÄ±yor...";
      case 'yolda':
      case 'yola Ã§Ä±ktÄ±':
        return "Kurye yola Ã§Ä±ktÄ±!";
      default:
        return "SipariÅŸiniz iÅŸleniyor";
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'yolda':
      case 'yola Ã§Ä±ktÄ±':
        return Colors.blueAccent;
      case 'onay bekliyor':
        return AppColors.warning;
      case 'hazÄ±rlanÄ±yor':
        return AppColors.primary;
      default:
        return AppColors.textPrimary;
    }
  }
}
