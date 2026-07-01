import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/models/campaign_model.dart';
import 'package:mugut_gelsin/pages/restaurant/restaurant_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/providers/address_provider.dart';
import 'dart:math' as math;

class RestaurantGrid extends StatelessWidget {
  final List<Restaurant> restaurants;
  final List<Campaign> campaigns;

  const RestaurantGrid({
    super.key, 
    required this.restaurants,
    this.campaigns = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: restaurants.map((res) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _RestaurantListTile(res: res, campaigns: campaigns),
          );
        }).toList(),
      ),
    );
  }
}

class _RestaurantListTile extends StatelessWidget {
  final Restaurant res;
  final List<Campaign> campaigns;

  const _RestaurantListTile({required this.res, this.campaigns = const []});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);
    final defaultAddress = addressProvider.defaultAddress;

    double? distance;
    if (defaultAddress != null) {
      final resLat = res.latitude ?? _getMockLatitude(res.id);
      final resLng = res.longitude ?? _getMockLongitude(res.id);
      final userLat = defaultAddress.latitude ?? 37.935;
      final userLng = defaultAddress.longitude ?? 58.390;
      distance = _calculateDistance(userLat, userLng, resLat, resLng);
    } else {
      final resLat = res.latitude ?? _getMockLatitude(res.id);
      final resLng = res.longitude ?? _getMockLongitude(res.id);
      distance = _calculateDistance(37.935, 58.390, resLat, resLng);
    }

    // Get campaigns for this restaurant
    final resCampaigns = campaigns.where((c) => c.shopId == res.id || c.shopId == res.docId).toList();
    List<String> tags = [];
    if (resCampaigns.isNotEmpty) {
      tags.addAll(resCampaigns.map((c) => c.title));
    } else {
      double maxDiscount = 0;
      for (var food in res.menu) {
        if (food.isCampaign && food.oldPrice != null && food.oldPrice! > food.price) {
          double discount = ((food.oldPrice! - food.price) / food.oldPrice!) * 100;
          if (discount > maxDiscount) {
            maxDiscount = discount;
          }
        }
      }
      final lang = langProvider.selectedLang;
      if (maxDiscount > 0) {
        final percent = maxDiscount.toStringAsFixed(0);
        tags.add(lang == 'TR' ? "Sana Özel - $percent% İndirim!" : (lang == 'TM' ? "Saňa ýörite - $percent% Arzanlaşyk!" : "Скидка до $percent%!"));
      } else if (res.menu.any((f) => f.isCampaign)) {
        tags.add(lang == 'TR' ? "Fırsat Ürünleri!" : (lang == 'TM' ? "Mümkinçilikler!" : "Акции!"));
      }
    }

    if (res.rating == "5.0") {
      tags.add("Yıldız Restoran");
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(restaurant: res),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: res.imageUrl,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      height: 80,
                      width: 80,
                      color: AppColors.surfaceSubtle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              res.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B1B1B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFF5D3EBC), size: 16),
                              const SizedBox(width: 2),
                              Text(
                                "${res.rating} (5000+)", // Mock reviews like screenshot
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5D3EBC),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF757D8A), size: 12),
                          const SizedBox(width: 2),
                          Text(
                            distance < 1.0 
                                ? "${(distance * 1000).toStringAsFixed(0)} m"
                                : "${distance.toStringAsFixed(1)} km",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF757D8A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),

                      // Delivery and Min Order
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF22923A), // Green bg
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              "R",
                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${res.deliveryTime} • Min ${res.minOrderAmount.toStringAsFixed(0)} TMT",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF757D8A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Tags (Campaigns)
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tags.map((tag) {
                    bool isYellow = tag.contains("İndirim") || tag.contains("Arzanlaşyk");
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isYellow ? const Color(0xFFFFD700) : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: isYellow ? null : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isYellow ? Icons.local_offer_rounded : Icons.star_rounded, 
                            color: isYellow ? const Color(0xFF4B32A3) : const Color(0xFFFFD700), 
                            size: 12
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tag,
                            style: GoogleFonts.inter(
                              color: isYellow ? const Color(0xFF4B32A3) : Colors.black87,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) *
        (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  double _getMockLatitude(String id) {
    final int hash = id.hashCode;
    final double offset = (hash % 100) / 1000.0 - 0.05; // -0.05 to 0.05
    return 37.935 + offset;
  }

  double _getMockLongitude(String id) {
    final int hash = id.hashCode;
    final double offset = ((hash ~/ 100) % 100) / 1000.0 - 0.05; // -0.05 to 0.05
    return 58.390 + offset;
  }
}
