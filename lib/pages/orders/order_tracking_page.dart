import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/models/order_model.dart';
import 'package:mugut_gelsin/providers/order_tracking_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/pages/orders/widgets/premium_review_dialog.dart';
import 'package:mugut_gelsin/pages/profile/live_support_page.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  bool _dialogShown = false;

  void _showReviewDialogIfNeeded(OrderModel order) {
    if (order.status == OrderStatus.delivered && !order.isRated && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PremiumReviewDialog(order: order),
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Light background for contrast
      body: StreamBuilder<OrderModel?>(
        stream: context.read<OrderTrackingProvider>().trackOrder(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(langProvider.get('error')));
          }
          final order = snapshot.data!;
          
          if (order.status == OrderStatus.delivered && !order.isRated) {
            _showReviewDialogIfNeeded(order);
          }

          return Stack(
            children: [
              // 1. Top 3D Banner
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/delivery_map_banner.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient overlay at bottom to blend smoothly
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFFF8F9FB).withOpacity(0.5),
                                const Color(0xFFF8F9FB),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Status Chip Overlay
                      Positioned(
                        bottom: 60,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getStatusTitle(order.status, langProvider),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getStatusSubtitle(order.status, langProvider, order.courierName),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Back button & Support button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LiveSupportPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.headset_mic_rounded, color: Colors.black, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              langProvider.get('support') ?? "Destek",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. White Card (Order details & Timeline)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.40,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sipariş No #${order.id.length >= 5 ? order.id.substring(0, 5).toUpperCase() : order.id.toUpperCase()}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy • HH:mm').format(order.timestamp),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFDF73), // Yellow button
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    "Detaylar",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.chevron_right, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Horizontal Timeline
                        _buildHorizontalTimeline(order, langProvider),

                        const SizedBox(height: 40),

                        // Courier Card
                        if (order.status.index >= OrderStatus.onWay.index && order.courierName != null)
                          _buildCourierCard(order, langProvider),
                          
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHorizontalTimeline(OrderModel order, LanguageProvider langProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double stepWidth = (width - 48) / 3; // 4 nodes -> 3 lines

        return Column(
          children: [
            SizedBox(
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Connecting lines
                  Positioned(
                    left: 24,
                    right: 24,
                    child: Row(
                      children: [
                        _buildTimelineLine(stepWidth, order.status.index >= OrderStatus.preparing.index),
                        _buildTimelineLine(stepWidth, order.status.index >= OrderStatus.onWay.index),
                        _buildTimelineLine(stepWidth, order.status.index >= OrderStatus.delivered.index),
                      ],
                    ),
                  ),
                  // Nodes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimelineNode(true, true, Icons.check),
                      _buildTimelineNode(order.status.index >= OrderStatus.preparing.index, order.status.index >= OrderStatus.preparing.index, Icons.check),
                      _buildTimelineNode(order.status.index >= OrderStatus.onWay.index, false, Icons.pedal_bike),
                      _buildTimelineNode(order.status.index >= OrderStatus.delivered.index, false, Icons.home_outlined),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Text labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimelineText("Sipariş Alındı", "09:30", true, 60),
                _buildTimelineText("Hazırlanıyor", "09:35", order.status.index >= OrderStatus.preparing.index, 70),
                _buildTimelineText("Yolda", "09:45", order.status.index >= OrderStatus.onWay.index, 60),
                _buildTimelineText("Teslim Edildi", "--:--", order.status.index >= OrderStatus.delivered.index, 70),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _buildTimelineLine(double width, bool isCompleted) {
    return Container(
      width: width,
      height: 3,
      color: isCompleted ? const Color(0xFFFFDF73) : Colors.grey.shade300,
    );
  }

  Widget _buildTimelineNode(bool isActive, bool isCheck, IconData icon) {
    if (isActive && isCheck) {
      return Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFFFFDF73),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.black, size: 24),
      );
    } else if (isActive && !isCheck) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
    } else {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Icon(icon, color: Colors.grey.shade400, size: 20),
      );
    }
  }

  Widget _buildTimelineText(String title, String time, bool isActive, double width) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.black87 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.black54 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourierCard(OrderModel order, LanguageProvider langProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset('assets/images/courier_avatar.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kurye",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  order.courierName ?? "Kurye",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      "4.9",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusTitle(OrderStatus status, LanguageProvider langProvider) {
    switch (status) {
      case OrderStatus.pending:
        return "Sipariş Alındı";
      case OrderStatus.preparing:
        return "Hazırlanıyor";
      case OrderStatus.onWay:
        return "Yolda";
      case OrderStatus.delivered:
        return "Teslim Edildi";
      case OrderStatus.cancelled:
        return "İptal Edildi";
    }
  }

  String _getStatusSubtitle(OrderStatus status, LanguageProvider langProvider, String? courier) {
    switch (status) {
      case OrderStatus.pending:
        return "Restoran siparişi onayladı.";
      case OrderStatus.preparing:
        return "Siparişiniz hazırlanıyor.";
      case OrderStatus.onWay:
        return "Siparişiniz adresinize doğru yolda.";
      case OrderStatus.delivered:
        return "Siparişiniz teslim edildi. Afiyet olsun!";
      case OrderStatus.cancelled:
        return "Bu sipariş iptal edilmiştir.";
    }
  }
}
