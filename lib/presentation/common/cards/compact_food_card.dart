import 'package:flutter/material.dart';
import 'package:mugt_gelsin/models/restaurant_model.dart';
import 'package:mugt_gelsin/providers/cart_provider.dart';
import 'package:mugt_gelsin/providers/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';
import 'package:mugt_gelsin/providers/navigation_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mugt_gelsin/presentation/common/widgets/hover_wrapper.dart';

class CompactFoodCard extends StatelessWidget {
  final Food food;
  final String? restaurantId;
  final String? restaurantName;
  final double? minOrderAmount;
  final VoidCallback? onTap;

  final GlobalKey _imageKey = GlobalKey();

  CompactFoodCard({
    super.key,
    required this.food,
    this.restaurantId,
    this.restaurantName,
    this.minOrderAmount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 14, bottom: 10, top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
        ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                      child: SizedBox(
                        key: _imageKey,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: food.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[100],
                            child: const Icon(Icons.fastfood, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Consumer<FavoriteProvider>(
                        builder: (context, favProvider, child) {
                          final isFav = favProvider.isFoodFavorite(food);
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
                                color: Colors.white.withValues(alpha: 0.95),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isFav ? Colors.red : Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // WHITE TITLE AREA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textTitle,
                      ),
                    ),
                    if (restaurantName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        restaurantName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // ORANGE ACTION AREA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(19)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${food.price} TL",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
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
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Icon(Icons.add, size: 16, color: AppColors.primary),
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
}
