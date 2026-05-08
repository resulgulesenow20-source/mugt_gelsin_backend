import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/presentation/common/widgets/hover_wrapper.dart';
import 'package:mugut_gelsin/pages/restaurant/food_detail_page.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final String? restaurantId;
  final String? restaurantName;
  final double? minOrderAmount;
  final VoidCallback? onTap;

  final GlobalKey _imageKey = GlobalKey();

  FoodCard({
    super.key, 
    required this.food,
    this.restaurantId,
    this.restaurantName,
    this.minOrderAmount,
    this.onTap,
  });

  Widget _buildSmartImage(String url) {
    if (url.startsWith('https') || url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: 85,
        height: 85,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _errorWidget(),
      );
    } else {
      return Image.asset(
        url,
        width: 85,
        height: 85,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorWidget(),
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
                      child: Container(
                        key: _imageKey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _buildSmartImage(food.imageUrl),
                        ),
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
                            style: GoogleFonts.outfit(
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
                            style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${food.price} TL",
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<FavoriteProvider>(
                          builder: (context, favProvider, child) {
                            final isFavorite = favProvider.isFoodFavorite(food);
                            return GestureDetector(
                              onTap: () => favProvider.toggleFoodFavorite(
                                FoodWithRestaurant(
                                  food: food,
                                  restaurantId: restaurantId ?? "",
                                  restaurantName: restaurantName ?? "",
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isFavorite ? AppColors.error.withAlpha(25) : AppColors.surfaceSubtle,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                  color: isFavorite ? AppColors.error : AppColors.textTertiary,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            context.read<CartProvider>().addToCart(
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
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppColors.premiumShadow,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
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
