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
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) {
          return _errorWidget();
        },
      );
    } else {
      return Image.asset(
        url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorWidget(),
      );
    }
  }

  Widget _errorWidget() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(Icons.fastfood, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Image
                    Hero(
                      tag: 'food_${food.id}_$restaurantId',
                      child: Container(
                        key: _imageKey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _buildSmartImage(food.imageUrl),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            food.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${food.price} TL",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isFavorite ? AppColors.error.withValues(alpha: 0.1) : AppColors.surfaceSubtle,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                  color: isFavorite ? AppColors.error : AppColors.textTertiary,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
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
                                content: Text("${food.name} added to cart!"),
                                backgroundColor: AppColors.primary,
                                duration: const Duration(milliseconds: 1500),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: AppColors.premiumShadow,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 24,
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

