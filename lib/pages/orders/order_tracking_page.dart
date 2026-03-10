import 'package:flutter/material.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';
import 'package:mugt_gelsin/models/order_model.dart';
import 'package:mugt_gelsin/providers/order_tracking_provider.dart';
import 'package:provider/provider.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Sipariş Takibi"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<OrderModel?>(
        stream: context.read<OrderTrackingProvider>().trackOrder(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Sipariş bulunamadı."));
          }

          final order = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(order),
                const SizedBox(height: 24),
                _buildStatusTimeline(order.status),
                const SizedBox(height: 24),
                _buildOrderDetails(order),
                const SizedBox(height: 40),
                _buildSupportButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(OrderModel order) {
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
                  "Sipariş No: ${order.id.substring(0, 8).toUpperCase()}",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${order.totalPrice.toStringAsFixed(2)} TL",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
              ),
              const Text("Toplam", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(OrderStatus status) {
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
            "Sipariş Alındı",
            "Siparişiniz dükkana iletildi",
            Icons.check_circle_rounded,
            status.index >= OrderStatus.pending.index,
            true,
          ),
          _buildTimelineDivider(status.index > OrderStatus.pending.index),
          _buildTimelineStep(
            "Hazırlanıyor",
            "Dükkan siparişinizi hazırlıyor",
            Icons.restaurant_rounded,
            status.index >= OrderStatus.preparing.index,
            status.index == OrderStatus.preparing.index,
          ),
          _buildTimelineDivider(status.index > OrderStatus.preparing.index),
          _buildTimelineStep(
            "Yolda",
            "Kurye siparişinizi getirmek için yola çıktı",
            Icons.delivery_dining_rounded,
            status.index >= OrderStatus.onWay.index,
            status.index == OrderStatus.onWay.index,
          ),
          _buildTimelineDivider(status.index > OrderStatus.onWay.index),
          _buildTimelineStep(
            "Teslim Edildi",
            "Afiyet olsun!",
            Icons.home_rounded,
            status.index >= OrderStatus.delivered.index,
            status.index == OrderStatus.delivered.index,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String desc, IconData icon, bool isCompleted, bool isActive) {
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
            child: const Text("Şu an", style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _buildOrderDetails(OrderModel order) {
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
          const Text("Sipariş Özeti", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 16),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${item.quantity}x ${item.name}", style: const TextStyle(fontSize: 14)),
                Text("${item.price.toStringAsFixed(2)} TL", style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          )),
          const Divider(height: 32),
          const Text("Teslimat Adresi", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
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

  Widget _buildSupportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          // Implement support navigation
        },
        icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
        label: const Text("Mugt Destek'e Bağlan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }
}
