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
  final bool restaurantIsOpen;
  final VoidCallback? onTap;

  final GlobalKey _imageKey = GlobalKey();

  FoodCard({
    super.key, 
    required this.food,
    this.restaurantId,
    this.restaurantName,
    this.minOrderAmount,
    this.restaurantIsOpen = true,
    this.onTap,
  });

  Widget _buildSmartImage(String url) {
    final imageWidget = url.startsWith('https') || url.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: url,
            width: 85,
            height: 85,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => _errorWidget(),
          )
        : Image.asset(
            url,
            width: 85,
            height: 85,
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
      width: 85,
      height: 85,
      color: Colors.grey[100],
      child: const Icon(Icons.fastfood, color: Colors.grey, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return HoverWrapper(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap ?? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodDetailPage(
                      food: food,
                      restaurantId: restaurantId,
                      restaurantName: restaurantName,
                      minOrderAmount: minOrderAmount,
                      restaurantIsOpen: restaurantIsOpen,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    // Image
                    Hero(
                      tag: 'food_${food.id}_$restaurantId',
                      child: Stack(
                        children: [
                          Container(
                            key: _imageKey,
                            padding: const EdgeInsets.all(6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildSmartImage(food.imageUrl),
                            ),
                          ),
                          if (food.isCampaign && food.oldPrice != null && food.oldPrice! > food.price)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "-${((food.oldPrice! - food.price) / food.oldPrice! * 100).round()}%",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            food.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "${food.price} TMT",
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (food.isCampaign && food.oldPrice != null && food.oldPrice! > food.price) ...[
                                const SizedBox(width: 8),
                                Text(
                                  "${food.oldPrice} TMT",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

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
                              );
                              
                              final navProvider = context.read<NavigationProvider>();
                              if (navProvider.runAddToCartAnimation != null) {
                                navProvider.runAddToCartAnimation!(_imageKey);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${food.name} eklendi!"),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              CartDialogs.showDifferentRestaurantDialog(
                                context: context,
                                food: food,
                                restaurantId: restaurantId,
                                restaurantName: restaurantName,
                                minOrderAmount: minOrderAmount,
                                onSuccess: () {
                                  final navProvider = context.read<NavigationProvider>();
                                  if (navProvider.runAddToCartAnimation != null) {
                                    navProvider.runAddToCartAnimation!(_imageKey);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Sepet boşaltıldı ve ${food.name} eklendi!"),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: restaurantIsOpen ? AppColors.primary : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: restaurantIsOpen ? AppColors.premiumShadow : null,
                            ),
                            child: Icon(
                              restaurantIsOpen ? Icons.add_rounded : Icons.lock_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
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
