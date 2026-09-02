import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mugut_gelsin/pages/orders/order_tracking_page.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/models/order_model.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class _AppBarLogo extends StatelessWidget {
  const _AppBarLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(-8.0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6.0, top: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(width: 12, height: 4, decoration: BoxDecoration(color: const Color(0xFFFFC824), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 4),
                    Container(width: 8, height: 4, decoration: BoxDecoration(color: const Color(0xFFFFC824), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 4),
                    Container(width: 16, height: 4, decoration: BoxDecoration(color: const Color(0xFFFFC824), borderRadius: BorderRadius.circular(2))),
                  ],
                ),
              ),
              Text(
                "m",
                style: GoogleFonts.nunito(
                  color: const Color(0xFF6BCC5E),
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                  height: 0.9,
                  letterSpacing: -2.0,
                ),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w900,
              fontSize: 26,
              height: 0.85,
              letterSpacing: -1.0,
            ),
            children: const [
              TextSpan(text: "gels", style: TextStyle(color: Color(0xFF6BCC5E))),
              TextSpan(text: "i", style: TextStyle(color: Color(0xFFFFC824))),
              TextSpan(text: "n", style: TextStyle(color: Color(0xFF6BCC5E))),
            ],
          ),
        ),
      ],
    );
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _selectedFilter = "all"; // "all", "30days", "active", "completed"

  Widget _buildFilterChip(String value, String labelText, String langCode) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD500) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFFFD500).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Text(
          labelText,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
            color: isSelected ? const Color(0xFF130A2A) : const Color(0xFF130A2A),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final langProvider = context.watch<LanguageProvider>();
    final langCode = langProvider.selectedLang;

    return Scaffold(
      backgroundColor: const Color(0xFF2B0F6B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B0F6B),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const _AppBarLogo(),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF9F7FC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sargytlarym",
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF130A2A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ähli sargytlaryňyz bir ýerde",
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD500),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.event_note_rounded, color: Color(0xFF130A2A)),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('all', 'Ählisi', langCode),
                  _buildFilterChip('30days', 'Soňky 30 gün', langCode),
                  _buildFilterChip('active', 'Aktiwwler', langCode),
                  _buildFilterChip('completed', 'Tamamlanan', langCode),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: currentUser == null
                  ? Center(child: Text(langProvider.translate('login_required')))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Emirler')
                          .where('customerUid', isEqualTo: currentUser.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF2B0F6B)));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("Sargyt tapylmady"));
                        }

                        final docs = snapshot.data!.docs;
                        var allOrders = docs.map((doc) => OrderModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
                        allOrders.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                        if (_selectedFilter == '30days') {
                          final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
                          allOrders = allOrders.where((order) => order.timestamp.isAfter(thirtyDaysAgo)).toList();
                        } else if (_selectedFilter == 'active') {
                          allOrders = allOrders.where((order) => 
                            order.status == OrderStatus.pending || 
                            order.status == OrderStatus.preparing || 
                            order.status == OrderStatus.onWay
                          ).toList();
                        } else if (_selectedFilter == 'completed') {
                          allOrders = allOrders.where((order) => order.status == OrderStatus.delivered).toList();
                        }

                        if (allOrders.isEmpty) {
                          return const Center(child: Text("Sargyt tapylmady."));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: allOrders.length,
                          itemBuilder: (context, index) {
                            return _NewOrderCardWidget(order: allOrders[index], langProvider: langProvider);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewOrderCardWidget extends StatelessWidget {
  final OrderModel order;
  final LanguageProvider langProvider;

  const _NewOrderCardWidget({required this.order, required this.langProvider});

  @override
  Widget build(BuildContext context) {
    Color statusBgColor;
    Color statusTextColor;
    String statusText;
    IconData statusIcon;

    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.preparing:
        statusBgColor = const Color(0xFFF3EDFA);
        statusTextColor = const Color(0xFF2B0F6B);
        statusText = "GARAŞYLYAR";
        statusIcon = Icons.access_time_filled;
        break;
      case OrderStatus.onWay:
        statusBgColor = const Color(0xFFFFF7CC);
        statusTextColor = const Color(0xFF130A2A);
        statusText = "ÝOLDA";
        statusIcon = Icons.delivery_dining;
        break;
      case OrderStatus.delivered:
        statusBgColor = const Color(0xFFE8F5E9);
        statusTextColor = const Color(0xFF2E7D32);
        statusText = "ELTİLDİ";
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        statusBgColor = const Color(0xFFFFEBEE);
        statusTextColor = const Color(0xFFC62828);
        statusText = "İPTAL";
        statusIcon = Icons.cancel;
        break;
    }

    String firstItemDesc = order.items.isNotEmpty ? "x " : "Sipariş";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 24,
            bottom: 24,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD500),
                borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2B0F6B),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          order.shopName.isNotEmpty ? order.shopName[0].toUpperCase() : 'M',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.shopName,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF130A2A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(order.timestamp),
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 16, color: statusTextColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: statusTextColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        firstItemDesc,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF130A2A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      " TMT",
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF130A2A)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderTrackingPage(orderId: order.id)),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2B0F6B)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Jikme-jikleri gör",
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2B0F6B)),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF2B0F6B)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
