import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/presentation/common/widgets/hover_wrapper.dart';
import 'package:mugut_gelsin/pages/restaurant/food_detail_page.dart';
import 'package:mugut_gelsin/widgets/cart_dialogs.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final String? restaurantId;
  final String? restaurantName;
  final double? minOrderAmount;
  final double? deliveryFee;
  final bool restaurantIsOpen;
  final String? deliveryTime;
  final VoidCallback? onTap;

  final GlobalKey _imageKey = GlobalKey();

  FoodCard({
    super.key, 
    required this.food,
    this.restaurantId,
    this.restaurantName,
    this.minOrderAmount,
    this.deliveryFee,
    this.restaurantIsOpen = true,
    this.deliveryTime,
    this.onTap,
  });

  Widget _buildSmartImage(String url) {
    final imageWidget = url.startsWith('https') || url.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: url,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => _errorWidget(),
          )
        : Image.asset(
            url,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _errorWidget(),
          );

    if (restaurantIsOpen) {
      return imageWidget;
    } else {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Opacity(
          opacity: 0.6,
          child: imageWidget,
        ),
      );
    }
  }

  Widget _errorWidget() {
    return Container(
      width: 88,
      height: 88,
      color: Colors.grey[100],
      child: const Icon(Icons.fastfood, color: Colors.grey, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return HoverWrapper(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap ?? () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => FoodDetailPage(
                      food: food,
                      restaurantId: restaurantId,
                      restaurantName: restaurantName,
                      minOrderAmount: minOrderAmount,
                      deliveryFee: deliveryFee,
                      restaurantIsOpen: restaurantIsOpen,
                      deliveryTime: deliveryTime,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image (88x88 px, 12px corner radius)
                      Hero(
                      tag: 'food_${food.id}_$restaurantId',
                      child: Container(
                        key: _imageKey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildSmartImage(food.imageUrl),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          if (food.isCampaign)
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_fire_department, size: 12, color: Color(0xFF22C55E)),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Popüler",
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF22C55E),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (restaurantName != null) ...[
                            Text(
                              restaurantName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            food.name,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            food.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              height: 1.2,
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                "30-40 dk",
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text("•", style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ),
                              const Icon(Icons.local_fire_department_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                "425 kcal",
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (food.isCampaign && food.oldPrice != null && food.oldPrice! > food.price)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Text(
                                    "${food.oldPrice}",
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              Text(
                                "${food.price} TMT",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22B573),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  if (!restaurantIsOpen) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(langProvider.get('shop_closed_warning')),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  final cartProvider = context.read<CartProvider>();
                                  
                                  if (cartProvider.canAddToCart(restaurantId)) {
                                    cartProvider.addToCart(
                                      food,
                                      restaurantId: restaurantId,
                                      restaurantName: restaurantName,
                                      minOrderAmount: minOrderAmount,
                                        deliveryFee: deliveryFee,
                                    );
                                    
                                    final navProvider = context.read<NavigationProvider>();
                                    if (navProvider.runAddToCartAnimation != null) {
                                      navProvider.runAddToCartAnimation!(_imageKey);
                                    }
                                  } else {
                                    CartDialogs.showDifferentRestaurantDialog(
                                      context: context,
                                      food: food,
                                      restaurantId: restaurantId,
                                      restaurantName: restaurantName,
                                      minOrderAmount: minOrderAmount,
                                        deliveryFee: deliveryFee,
                                      onSuccess: () {
                                        final navProvider = context.read<NavigationProvider>();
                                        if (navProvider.runAddToCartAnimation != null) {
                                          navProvider.runAddToCartAnimation!(_imageKey);
                                        }
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: restaurantIsOpen ? const Color(0xFF22C55E) : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: restaurantIsOpen ? AppColors.premiumShadow : null,
                                  ),
                                  child: Icon(
                                    restaurantIsOpen ? Icons.add_rounded : Icons.lock_outline,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
