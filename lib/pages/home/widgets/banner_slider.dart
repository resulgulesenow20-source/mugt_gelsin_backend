import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/models/campaign_model.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BannerSlider extends StatefulWidget {
  final List<Campaign>? campaigns;
  final List<Restaurant> restaurants;
  final Function(String) onRestaurantSelected;
  final Function(String) onCategorySelected;

  const BannerSlider({
    super.key,
    this.campaigns,
    required this.restaurants,
    required this.onRestaurantSelected,
    required this.onCategorySelected,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late final PageController _pageController;
  late int _currentPage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final campaigns = widget.campaigns ?? [];
    final featuredRestaurants = widget.restaurants.take(6).toList();
    final totalCount = campaigns.length + featuredRestaurants.length;
    
    // Set a large initial page that is a multiple of totalCount to allow scrolling in both directions
    int initialPage = 0;
    if (totalCount > 0) {
      initialPage = totalCount * 100;
    }
    _currentPage = initialPage;
    _pageController = PageController(initialPage: initialPage);

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final campaigns = widget.campaigns ?? [];
      final featuredRestaurants = widget.restaurants.take(6).toList();
      int totalItems = campaigns.length + featuredRestaurants.length;
      if (totalItems <= 1) return;

      _currentPage++;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = widget.campaigns ?? [];
    final featuredRestaurants = widget.restaurants.take(6).toList();
    final totalCount = campaigns.length + featuredRestaurants.length;

    if (totalCount == 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final realIndex = index % totalCount;
          if (realIndex < campaigns.length) {
            return _buildCampaignItem(campaigns[realIndex], realIndex, totalCount);
          }
          final restaurantIndex = realIndex - campaigns.length;
          return _buildRestaurantBannerItem(featuredRestaurants[restaurantIndex], realIndex, totalCount);
        },
      ),
    );
  }

  Widget _buildCampaignItem(Campaign camp, int itemIndex, int totalCount) {
    final bool hasImage = camp.imageUrl != null && camp.imageUrl!.isNotEmpty;
    
    return AnimatedScale(
      scale: (_currentPage % totalCount) == itemIndex ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 500),
      child: Consumer<LanguageProvider>(
        builder: (context, lang, child) => GestureDetector(
          onTap: () {
            if (camp.shopId.isNotEmpty) {
              widget.onRestaurantSelected(camp.shopId);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: hasImage
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              boxShadow: [
                BoxShadow(
                  color: (hasImage ? Colors.black : AppColors.primary).withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  if (hasImage) ...[
                    Positioned.fill(
                      child: camp.imageUrl!.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: camp.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => const Center(
                                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                            )
                          : Image.asset(
                              camp.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                            ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.2),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.local_offer,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasImage ? AppColors.secondary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            camp.type == 'coupon' ? lang.get('coupon_code_label') : lang.get('special_offer_label'),
                            style: TextStyle(
                              color: hasImage ? AppColors.textPrimary : AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          camp.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          camp.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (camp.code != null && camp.code!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(
                              "${lang.get('code_label')}: ${camp.code}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantBannerItem(Restaurant res, int itemIndex, int totalCount) {
    return AnimatedScale(
      scale: (_currentPage % totalCount) == itemIndex ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 500),
      child: Consumer<LanguageProvider>(
        builder: (context, lang, child) => GestureDetector(
          onTap: () => widget.onRestaurantSelected(res.id),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: res.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: res.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.primary.withOpacity(0.05),
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.storefront, size: 50, color: AppColors.primary),
                            ),
                          )
                        : Image.asset(
                            res.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.storefront, size: 50, color: AppColors.primary),
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.2),
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lang.get('campaign_label'),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          res.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              res.rating,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "•  ${lang.get('delivery_time')}: ${res.deliveryTime}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
