import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/pages/restaurant/restaurant_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/providers/address_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/presentation/common/widgets/hover_wrapper.dart';
import 'package:mugut_gelsin/presentation/common/widgets/restaurant_rating_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:mugut_gelsin/models/campaign_model.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart';
import 'package:mugut_gelsin/providers/region_provider.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant res;
  final double? imageHeight;
  final bool isCompact;
  final List<Campaign> campaigns;

  const RestaurantCard({
    super.key,
    required this.res,
    this.imageHeight,
    this.isCompact = false,
    this.campaigns = const [],
  });

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

    // Prepare campaign text
    String campaignText = '';
    final resCampaigns = campaigns.where((c) => c.shopId == res.id || c.shopId == res.docId).toList();
    if (resCampaigns.isNotEmpty) {
      campaignText = resCampaigns.first.title;
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
        if (lang == 'TR') {
          campaignText = "%$percent'e Varan İndirim!";
        } else if (lang == 'TM') {
          campaignText = "%$percent-e çenli arzanlaşyk!";
        } else {
          campaignText = "Скидка до $percent%!";
        }
      } else if (res.menu.any((f) => f.isCampaign)) {
        if (lang == 'TR') {
          campaignText = "Sana Özel İndirimler!";
        } else if (lang == 'TM') {
          campaignText = "Saňa ýörite arzanlaşyk!";
        } else {
          campaignText = "Специальные скидки!";
        }
      }
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
      borderRadius: BorderRadius.circular(8),
      child: HoverWrapper(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Image Section ---
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 6, right: 6),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: res.isOpen
                        ? CachedNetworkImage(
                            imageUrl: res.imageUrl,
                            height: imageHeight ?? 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: imageHeight ?? 140,
                              color: AppColors.surfaceSubtle,
                              child: const Center(
                                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: imageHeight ?? 140,
                              color: AppColors.surfaceSubtle,
                              child: const Icon(Icons.fastfood_rounded, color: AppColors.textTertiary, size: 40),
                            ),
                          )
                        : ColorFiltered(
                            colorFilter: const ColorFilter.matrix(<double>[
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      1, 0,
                            ]),
                            child: Opacity(
                              opacity: 0.6,
                              child: CachedNetworkImage(
                                imageUrl: res.imageUrl,
                                height: imageHeight ?? 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(height: imageHeight ?? 140, color: AppColors.surfaceSubtle),
                              ),
                            ),
                          ),
                  ),

                  // Campaign Tag (Top Left)
                  if (campaignText.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4B32A3), // Purple bg like screenshot
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFD700), width: 1.5), // Yellow border
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_offer_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              campaignText,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Closed Badge
                  if (!res.isOpen)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              langProvider.get('shop_closed').toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Distance Badge (Bottom Left)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF5A6675), size: 12),
                          const SizedBox(width: 2),
                          Text(
                            distance < 1.0 
                                ? "${(distance * 1000).toStringAsFixed(0)} m"
                                : "${distance.toStringAsFixed(1)} km",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF5A6675),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ),

              // --- Details Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Name and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            res.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B1B1B), // Dark near-black
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.orange, size: 16), // Orange star
                            const SizedBox(width: 2),
                            RestaurantRatingText(
                              restaurantId: res.id,
                              docId: res.docId,
                              rating: res.rating,
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),

                    // Row 2: Delivery & Min Order and Sponsorlu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                            Builder(
                              builder: (context) {
                                final addressProvider = Provider.of<AddressProvider>(context, listen: false);
                                final defaultAddress = addressProvider.defaultAddress;
                                double? userLat = defaultAddress?.latitude;
                                double? userLng = defaultAddress?.longitude;
                                
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                final regionProvider = Provider.of<RegionProvider>(context, listen: false);
                                String? currentRegion;
                                String? currentDistrict;
                                if (authProvider.isLoggedIn && defaultAddress != null) {
                                  currentRegion = defaultAddress.city;
                                  currentDistrict = defaultAddress.district;
                                } else {
                                  currentRegion = regionProvider.selectedGuestRegion;
                                }

                                final activeZone = res.getActiveZone(userLat, userLng, userRegion: currentRegion, userDistrict: currentDistrict);
                                double displayMinOrder = activeZone != null ? activeZone.minOrder : res.minOrderAmount;
                                String displayDeliveryTime = activeZone != null && activeZone.deliveryTime.isNotEmpty
                                    ? activeZone.deliveryTime 
                                    : res.deliveryTime;
                                
                                return Text(
                                  "$displayDeliveryTime • Min ${displayMinOrder.toStringAsFixed(0)} TMT",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF757D8A),
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                        // Sponsorlu text omitted to avoid build error with res.isSponsored
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
