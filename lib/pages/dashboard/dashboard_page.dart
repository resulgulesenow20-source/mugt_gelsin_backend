import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/services/api_service.dart';
import 'package:mugut_gelsin/models/campaign_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart';
import 'package:mugut_gelsin/pages/home/widgets/daily_offer_widget.dart';
import 'package:mugut_gelsin/pages/home/widgets/wallet_progress_widget.dart';
import 'package:mugut_gelsin/pages/home/widgets/active_order_widget.dart';
import 'package:mugut_gelsin/pages/home/daily_offers_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.displayName ?? 'Myhman';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BANNER
            ClipPath(
              clipper: WavyBottomClipper(),
              child: Container(
                width: double.infinity,
                height: 320, // Taller height to match mockup
                decoration: const BoxDecoration(
                  color: Color(0xFF2B0F6B),
                ),
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('DashboardBanners').limit(1).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "Kampanya Görseli Bulunamadı\nLütfen Admin Panel'den ekleyin.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    
                    final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                    String? imageUrl = data['imageUrl'] ?? data['image_url'] ?? data['Resim'];
                    
                    if (imageUrl == null || imageUrl.isEmpty) {
                      return const Center(
                        child: Text(
                          "Kampanya Görseli Bulunamadı",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    if (imageUrl.startsWith('static/')) {
                      imageUrl = '/';
                    }

                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      width: double.infinity,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white)),
                    );
                  },
                ),
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Bell
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("👋", style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(
                                "Salam, \!",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Sana Özel Özet",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2B0F6B),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      // Notification Bell
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EDFA),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Color(0xFF130A2A), size: 24),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5D3EBC),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Row for TMT and Offers
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 4, 
                          child: DailyOfferWidget(
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                              );
                              final restaurants = await ApiService().fetchRestaurants();
                              Navigator.pop(context); // close dialog
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DailyOffersPage(restaurants: restaurants),
                                ),
                              );
                            },
                          ),
                        ),
                        if (authProvider.isLoggedIn) ...[
                          const SizedBox(width: 8),
                          const Expanded(flex: 5, child: WalletProgressWidget()),
                        ]
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // Sargytlarym Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sargytlarym (7)",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B0F6B),
                          fontFamily: 'Inter',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to orders tab
                        },
                        child: const Row(
                          children: [
                            Text(
                              "Ählisini gör",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5D3EBC),
                              ),
                            ),
                            Icon(Icons.arrow_forward_rounded, color: Color(0xFF5D3EBC), size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const ActiveOrderWidget(),

                  const SizedBox(height: 24),

                  // Promotional Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B0F6B),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD500),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Täze müşderiler üçin",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF130A2A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "İlkinji sargydyňa 20 TMT indirim!",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Sargyt et",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B0F6B),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_rounded, color: Color(0xFF2B0F6B), size: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Gift Icon (using an icon instead of 3d asset if not available)
                        const Icon(Icons.card_giftcard_rounded, color: Color(0xFFFFD500), size: 80),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Bottom nav bar boşluğu
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WavyBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30); // Start higher on the left

    // Gentle S-Curve similar to mockup
    var firstControlPoint = Offset(size.width * 0.35, size.height - 45);
    var firstEndPoint = Offset(size.width * 0.65, size.height - 15);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 0.85, size.height);
    var secondEndPoint = Offset(size.width, size.height - 10);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
