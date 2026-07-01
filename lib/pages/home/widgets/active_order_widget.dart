import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mugut_gelsin/pages/orders/order_tracking_page.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';

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
    
    final langProvider = Provider.of<LanguageProvider>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Emirler')
          .where('customerUid', isEqualTo: user.uid)
          .where('status', whereIn: ['pending', 'hazırlanıyor', 'yolda', 'yola çıktı', 'onay bekliyor', 'onaylanıyor', 'on_the_way'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("ActiveOrderWidget Error: ${snapshot.error}");
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['timestamp'];
          final bTime = (b.data() as Map<String, dynamic>)['timestamp'];
          
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime); 
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
                    docs.length > 1 ? "${langProvider.translate('orders')} (${docs.length})" : langProvider.translate('orders'),
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
              height: 155, 
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
                  final String status = orderData['status'] ?? 'hazırlanıyor';
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    _buildOrderImage(orderData, status),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        shopName,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      langProvider.translate('order_detail'),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTimeline(status, langProvider),
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

  Widget _buildTimeline(String status, LanguageProvider langProvider) {
    int currentStep = 0;
    final s = status.toLowerCase();
    if (s.contains('onay') || s.contains('pending')) {
      currentStep = 0;
    } else if (s.contains('hazırlanıyor') || s.contains('hazirlaniyor')) {
      currentStep = 1;
    } else if (s.contains('yolda') || s.contains('yola çıktı') || s.contains('on_the_way')) {
      currentStep = 2;
    } else if (s.contains('teslim') || s.contains('delivered')) {
      currentStep = 3;
    } else {
      currentStep = 1; 
    }

    final steps = [
      langProvider.translate('order_received'),
      langProvider.translate('preparing'),
      langProvider.translate('on_the_way'),
      langProvider.translate('delivered'),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index % 2 != 0) {
          int stepIndex = index ~/ 2;
          bool isCompleted = currentStep > stepIndex;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              height: 3,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        } else {
          int stepIndex = index ~/ 2;
          bool isActive = currentStep >= stepIndex;
          bool isCurrent = currentStep == stepIndex;
          
          return Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.green : Colors.grey[200],
                  border: isCurrent ? Border.all(color: Colors.green.withOpacity(0.3), width: 4) : null,
                  boxShadow: isCurrent ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 6)] : null,
                ),
                child: isActive 
                    ? const Icon(Icons.check, size: 14, color: Colors.white) 
                    : null,
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 55,
                child: Text(
                  steps[stepIndex],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive ? Colors.green : Colors.grey[500],
                    height: 1.1,
                  ),
                ),
              ),
            ],
          );
        }
      }),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildOrderImage(Map<String, dynamic> orderData, String status) {
    final items = orderData['items'] as List? ?? [];
    String imageUrl = '';
    if (items.isNotEmpty) {
      final firstItem = items[0] as Map<String, dynamic>?;
      if (firstItem != null) {
        imageUrl = (firstItem['imageUrl'] ?? firstItem['image_url'] ?? firstItem['Resim'] ?? '') as String;
      }
    }

    // Get status configurations (color and icon)
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

    Widget imageWidget;
    if (imageUrl.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 50,
          height: 50,
          color: AppColors.surfaceSubtle,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 50,
          height: 50,
          color: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 22),
        ),
      );
    } else {
      imageWidget = Container(
        width: 50,
        height: 50,
        color: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 22),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageWidget,
        ),
        // Tiny status badge overlay in the bottom-right corner
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
              ],
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
        ),
      ],
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
