import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/pages/restaurant/restaurant_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/providers/address_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/presentation/common/widgets/hover_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:mugut_gelsin/models/campaign_model.dart';

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

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(restaurant: res),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: HoverWrapper(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: res.isOpen
                        ? CachedNetworkImage(
                            imageUrl: res.imageUrl,
                            height: imageHeight ?? 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: imageHeight ?? 130,
                              color: AppColors.surfaceSubtle,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: imageHeight ?? 130,
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
                                height: imageHeight ?? 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: imageHeight ?? 130,
                                  color: AppColors.surfaceSubtle,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: imageHeight ?? 130,
                                  color: AppColors.surfaceSubtle,
                                  child: const Icon(Icons.fastfood_rounded, color: AppColors.textTertiary, size: 40),
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (!res.isOpen)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 10,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded, 
                              color: AppColors.primary, 
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distance < 1.0 
                                  ? "${(distance * 1000).toStringAsFixed(0)} m"
                                  : "${distance.toStringAsFixed(1)} km",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],

              ),
              Padding(
                padding: EdgeInsets.all(isCompact ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        res.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: isCompact ? 15 : 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isCompact) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            res.rating,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "•",
                            style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time_filled_rounded, color: Colors.orangeAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            res.deliveryTime,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Column 1: Rating
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                                const SizedBox(height: 4),
                                Text(
                                  res.rating,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  langProvider.selectedLang == 'TR' 
                                      ? 'Puan' 
                                      : (langProvider.selectedLang == 'TM' ? 'Dereje' : 'Рейтинг'),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider 1
                          Container(height: 30, width: 1, color: Colors.grey.shade200),
                          // Column 2: Delivery Time
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_filled_rounded, color: Colors.orangeAccent, size: 22),
                                const SizedBox(height: 4),
                                Text(
                                  res.deliveryTime,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  langProvider.selectedLang == 'TR' 
                                      ? 'Teslimat' 
                                      : (langProvider.selectedLang == 'TM' ? 'Eltip berme' : 'Доставка'),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider 2
                          Container(height: 30, width: 1, color: Colors.grey.shade200),
                          // Column 3: Today's Hours
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.alarm_rounded, color: Colors.blueAccent, size: 22),
                                const SizedBox(height: 4),
                                Text(
                                  "${res.openingTime ?? '09:00'} - ${res.closingTime ?? '22:00'}",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  langProvider.selectedLang == 'TR' 
                                      ? 'Saatler' 
                                      : (langProvider.selectedLang == 'TM' ? 'Sagatlar' : 'Часы'),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Min: ${res.minOrderAmount.toStringAsFixed(0)} TMT  •  ${res.category}",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              () {
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
                      campaignText = "%$percent'e Varan İndirimler!";
                    } else if (lang == 'TM') {
                      campaignText = "%$percent-e çenli arzanlaşyk!";
                    } else {
                      campaignText = "Скидки до $percent%!";
                    }
                  } else if (res.menu.any((f) => f.isCampaign)) {
                    if (lang == 'TR') {
                      campaignText = "Kampanyalı Ürünler Fırsatı!";
                    } else if (lang == 'TM') {
                      campaignText = "Kampaniýaly önümler!";
                    } else {
                      campaignText = "Акционные товары!";
                    }
                  }
                }

                if (campaignText.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 12 : 16, 
                      vertical: isCompact ? 6 : 8,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF9E6), // Soft cream yellow
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                      border: Border(top: BorderSide(color: Color(0xFFFFF2CC), width: 1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer_rounded, color: Color(0xFFFF9F00), size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            campaignText,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFB27A00), // Rich dark gold
                              fontWeight: FontWeight.bold,
                              fontSize: isCompact ? 11 : 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }(),
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

