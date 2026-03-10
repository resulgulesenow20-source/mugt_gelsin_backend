import 'package:flutter/material.dart';
import 'package:mugt_gelsin/models/restaurant_model.dart';
import 'package:mugt_gelsin/providers/cart_provider.dart';
import 'package:mugt_gelsin/providers/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';
import 'package:mugt_gelsin/providers/navigation_provider.dart';

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
    print("Resim URL: $url"); // Debug için
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Hata: $error"); // Hata detayını gör
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
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
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          food.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              "${food.price} TL",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
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
                                color: isFavorite ? Colors.red.withOpacity(0.1) : AppColors.surfaceSubtle,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                color: isFavorite ? Colors.red : AppColors.textSecondary,
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
                          
                          // Trigger Add to Cart Animation
                          final navProvider = context.read<NavigationProvider>();
                          if (navProvider.runAddToCartAnimation != null) {
                            navProvider.runAddToCartAnimation!(_imageKey);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${food.name} sepete eklendi!"),
                              backgroundColor: AppColors.primary,
                              duration: const Duration(milliseconds: 1500),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppColors.orangeGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
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
    );
  }
}
