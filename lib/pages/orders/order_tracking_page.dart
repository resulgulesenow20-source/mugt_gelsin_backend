import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/models/order_model.dart';
import 'package:mugut_gelsin/providers/order_tracking_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/pages/orders/widgets/premium_review_dialog.dart';
import 'package:mugut_gelsin/pages/profile/live_support_page.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      
      // Build tamamlandıktan sonra dialog'u göster
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        
        await showDialog(
          context: context,
          barrierDismissible: false, // Değerlendirme yapmadan geçmesin (veya çıkınca pop olsun)
          builder: (context) => PremiumReviewDialog(order: order),
        );
        
        // Dialog kapandığında (puan verildikten veya vazgeçildikten sonra) takip sayfasından çık
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(langProvider.translate('order_tracking')),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
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
          
          // Otomatik değerlendirme kontrolü
          if (order.status == OrderStatus.delivered && !order.isRated) {
            _showReviewDialogIfNeeded(order);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(order, langProvider),
                const SizedBox(height: 24),
                _buildStatusTimeline(order, langProvider),
                const SizedBox(height: 24),
                _buildOrderDetails(order, langProvider),
                if (order.status == OrderStatus.delivered && !order.isRated) ...[
                  const SizedBox(height: 24),
                  _buildRateButton(context, order, langProvider),
                ],
                const SizedBox(height: 40),
                _buildSupportButton(context, langProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(OrderModel order, LanguageProvider langProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.shopName,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  "${langProvider.translate('order_no')}: ${order.id.substring(0, 8).toUpperCase()}",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${order.totalPrice.toStringAsFixed(2)} TMT",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
              ),
              Text(langProvider.translate('total_price'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(OrderModel order, LanguageProvider langProvider) {
    final status = order.status;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          _buildTimelineStep(
            langProvider.translate('order_received'),
            langProvider.translate('order_received_desc'),
            Icons.check_circle_rounded,
            status.index >= OrderStatus.pending.index,
            status.index == OrderStatus.pending.index,
            langProvider,
          ),
          _buildTimelineDivider(status.index > OrderStatus.pending.index),
          _buildTimelineStep(
            langProvider.translate('preparing'),
            langProvider.translate('preparing_desc'),
            Icons.restaurant_rounded,
            status.index >= OrderStatus.preparing.index,
            status.index == OrderStatus.preparing.index,
            langProvider,
          ),
          _buildTimelineDivider(status.index > OrderStatus.preparing.index),
          _buildTimelineStep(
            langProvider.translate('on_the_way'),
            order.status == OrderStatus.onWay && order.courierName != null
                ? "${order.shopName} ${langProvider.get('courier') ?? 'kuryesi'} ${order.courierName} ${langProvider.get('on_the_way_desc')}"
                : langProvider.get('on_the_way_desc'),
            Icons.delivery_dining_rounded,
            status.index >= OrderStatus.onWay.index,
            status.index == OrderStatus.onWay.index,
            langProvider,
          ),
          _buildTimelineDivider(status.index > OrderStatus.onWay.index),
          _buildTimelineStep(
            langProvider.translate('delivered'),
            langProvider.translate('enjoy_meal'),
            Icons.home_rounded,
            status.index >= OrderStatus.delivered.index,
            status.index == OrderStatus.delivered.index,
            langProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String desc, IconData icon, bool isCompleted, bool isActive, LanguageProvider langProvider) {
    Color color = isCompleted ? AppColors.primary : Colors.grey.shade300;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isCompleted ? AppColors.textPrimary : Colors.grey,
                ),
              ),
              Text(
                desc,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        ),
        if (isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(langProvider.translate('now'), style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildTimelineDivider(bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      height: 30,
      width: 2,
      color: isCompleted ? AppColors.primary : Colors.grey.shade200,
    );
  }

  Widget _buildOrderDetails(OrderModel order, LanguageProvider langProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(langProvider.translate('order_summary'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 16),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl ?? '',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, color: Colors.grey, size: 16),
                    ),
                    placeholder: (context, url) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[100],
                      child: const Center(
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${item.quantity}x ${item.name}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  "${item.price.toStringAsFixed(2)} TMT",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )),
          const Divider(height: 32),
          Text(langProvider.translate('delivery_address'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportButton(BuildContext context, LanguageProvider langProvider) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LiveSupportPage()),
          );
        },
        icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
        label: Text(langProvider.translate('connect_support'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildRateButton(BuildContext context, OrderModel order, LanguageProvider langProvider) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => PremiumReviewDialog(order: order),
          ).then((_) {
            // Dialog elle kapatıldığında da çıkmak gerekirse eklenebilir
          });
        },
        icon: const Icon(Icons.star_rate_rounded, color: Colors.amber),
        label: Text(langProvider.translate('rate_order'), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }
}
