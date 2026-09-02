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
    final totalCount = campaigns.length;
    
    // Set a large initial page that is a multiple of totalCount to allow scrolling in both directions
    int initialPage = 0;
    if (totalCount > 0) {
      initialPage = totalCount * 100;
    }
    _currentPage = initialPage;
    _pageController = PageController(initialPage: initialPage, viewportFraction: 0.88);

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final campaigns = widget.campaigns ?? [];
      int totalItems = campaigns.length;
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
    final totalCount = campaigns.length;

    if (totalCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
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
              Widget bannerItem = _buildCampaignItem(campaigns[realIndex], realIndex, totalCount);

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_pageController.position.haveDimensions) {
                    scale = _pageController.page! - index;
                    scale = (1 - (scale.abs() * 0.05)).clamp(0.95, 1.0);
                  } else {
                    scale = _currentPage == index ? 1.0 : 0.95;
                  }
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: bannerItem,
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalCount, (index) {
            final int realIndex = _currentPage % totalCount;
            final bool isActive = index == realIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCampaignItem(Campaign camp, int itemIndex, int totalCount) {
    final bool hasImage = camp.imageUrl != null && camp.imageUrl!.isNotEmpty;
    
    return Consumer<LanguageProvider>(
        builder: (context, lang, child) => GestureDetector(
          onTap: () {
            if (camp.shopId.isNotEmpty) {
              widget.onRestaurantSelected(camp.shopId);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(left: 4, right: 4, top: 10, bottom: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2),
              color: const Color(0xFF2B0F6B),
              boxShadow: hasImage ? [] : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
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
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "LEZZETLİ YEMEKLER",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const Text(
                                  "KAPINDA!",
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "En sevdiğin restoranlardan\nhızlı ve güvenli teslimat.",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.2,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.delivery_dining, color: Colors.black, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        "FREE DELIVERY",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Image.asset(
                              'assets/images/hamburger.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.centerRight,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.fastfood,
                                color: Colors.white24,
                                size: 80,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildRestaurantBannerItem(Restaurant res, int itemIndex, int totalCount) {
    return Consumer<LanguageProvider>(
        builder: (context, lang, child) => GestureDetector(
          onTap: () => widget.onRestaurantSelected(res.id),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
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
    );
  }
}
