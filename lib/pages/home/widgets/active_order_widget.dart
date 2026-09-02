import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mugut_gelsin/pages/orders/order_tracking_page.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/utils/distance_calculator.dart';
import 'package:mugut_gelsin/providers/address_provider.dart';

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
          // Removed whereIn to avoid composite index requirement
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("ActiveOrderWidget Error: ${snapshot.error}");
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final activeStatuses = ['pending', 'hazırlanıyor', 'yolda', 'yola çıktı', 'onay bekliyor', 'onaylanıyor', 'on_the_way'];
        var docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['status'] ?? '').toString().toLowerCase();
          return activeStatuses.contains(status);
        }).toList();

        if (docs.isEmpty) {
          return const SizedBox.shrink();
        }

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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    docs.length > 1 ? "${langProvider.translate('orders')} (${docs.length})" : langProvider.translate('orders'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5D3EBC), // Dark Green
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(
              height: 250, 
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
                  final double totalPrice = (orderData['total_price'] ?? 0).toDouble();

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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Header Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildAvatar(orderData),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shopName,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                        color: Color(0xFF2E1A47),
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Sipariş içeriği",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance.collection('Restoranlar').doc(orderData['shop_id']).get(),
                                      builder: (context, resSnap) {
                                        String prepTime = "20-30 dk";
                                        String distanceStr = "1.5 km";
                                        
                                        if (resSnap.hasData && resSnap.data!.exists) {
                                          final resData = resSnap.data!.data() as Map<String, dynamic>;
                                          if (resData['preparation_time'] != null) {
                                            prepTime = "${resData['preparation_time']} dk";
                                          }
                                          final userLat = context.read<AddressProvider>().defaultAddress?.latitude;
                                          final userLng = context.read<AddressProvider>().defaultAddress?.longitude;
                                          final resLat = resData['latitude'];
                                          final resLng = resData['longitude'];
                                          
                                          if (userLat != null && userLng != null && resLat != null && resLng != null) {
                                            double dist = DistanceCalculator.calculateDistanceKm(userLat, userLng, resLat, resLng);
                                            distanceStr = dist < 1.0 ? "${(dist * 1000).toStringAsFixed(0)} m" : "${dist.toStringAsFixed(1)} km";
                                          }
                                        }

                                        return Row(
                                          children: [
                                            _buildPill(Icons.access_time_rounded, prepTime),
                                            const SizedBox(width: 8),
                                            _buildPill(Icons.location_on_rounded, distanceStr),
                                          ],
                                        );
                                      }
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${totalPrice.toStringAsFixed(0)} TMT",
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2E1A47),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 16),
                          
                          // Timeline Section
                          _buildTimeline(status, orderData, langProvider),
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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "--:--";
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      date = DateTime.now();
    }
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildAvatar(Map<String, dynamic> orderData) {
    final items = orderData['items'] as List? ?? [];
    String imageUrl = '';
    if (items.isNotEmpty) {
      final firstItem = items[0] as Map<String, dynamic>?;
      if (firstItem != null) {
        imageUrl = (firstItem['imageUrl'] ?? firstItem['image_url'] ?? firstItem['Resim'] ?? '') as String;
      }
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF2E1A47),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                errorWidget: (context, url, error) => const Icon(Icons.fastfood, color: Colors.white, size: 32),
              )
            : const Icon(Icons.fastfood, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEF9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2E1A47)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12, 
              color: Color(0xFF2E1A47), 
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDottedLine() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 3.0;
          const dashSpace = 3.0;
          final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
          return Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.grey[400]),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(String status, Map<String, dynamic> orderData, LanguageProvider langProvider) {
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
      {'title': 'Sipariş alındı', 'icon': Icons.check, 'time': _formatDate(orderData['timestamp'])},
      {'title': 'Hazırlanıyor', 'icon': Icons.restaurant, 'time': _formatDate(orderData['preparing_time'])},
      {'title': 'Yolda', 'icon': Icons.moped_rounded, 'time': _formatDate(orderData['on_way_time'])},
      {'title': 'Teslim edildi', 'icon': Icons.home_outlined, 'time': _formatDate(orderData['delivered_time'])},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index % 2 != 0) {
              int stepIndex = index ~/ 2;
              bool isLineActive = currentStep > stepIndex;
              if (isLineActive) {
                return Expanded(
                  child: Container(
                    height: 2,
                    color: const Color(0xFFFFD500), // Solid Yellow line
                  ),
                );
              } else {
                return _buildDottedLine();
              }
            } else {
              int stepIndex = index ~/ 2;
              bool isCompleted = currentStep > stepIndex;
              bool isActive = currentStep == stepIndex;
              bool isPending = currentStep < stepIndex;

              return SizedBox(
                width: 60,
                child: Center(
                  child: Builder(
                    builder: (context) {
                      if (isCompleted) {
                        return Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD500),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(steps[stepIndex]['icon'] as IconData, color: const Color(0xFF2E1A47), size: 20),
                        );
                      } else if (isActive) {
                        return Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3EEF9),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E1A47),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(steps[stepIndex]['icon'] as IconData, color: Colors.white, size: 20),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFD500),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Pending
                        return Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: Icon(steps[stepIndex]['icon'] as IconData, color: Colors.grey.shade400, size: 20),
                        );
                      }
                    }
                  ),
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(steps.length, (index) {
            final isActive = index == currentStep;
            final isCompleted = index < currentStep;
            
            return SizedBox(
              width: 70,
              child: Column(
                children: [
                  Text(
                    steps[index]['title'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: (isActive || isCompleted) ? FontWeight.bold : FontWeight.w500,
                      color: (isActive || isCompleted) ? const Color(0xFF2E1A47) : Colors.grey[600],
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    steps[index]['time'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'onay bekliyor':
        return "Garaşylýar";
      case 'hazırlanıyor':
        return "Taýýarlanýar";
      case 'yolda':
      case 'yola çıktı':
        return "Yolda";
      default:
        return "Taýýar";
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
