import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mugut_gelsin/presentation/common/widgets/hover_wrapper.dart';
import 'package:mugut_gelsin/widgets/cart_dialogs.dart';

class CompactFoodCard extends StatelessWidget {
  final Food food;
  final String? restaurantId;
  final String? restaurantName;
  final double? minOrderAmount;
  final double? deliveryFee;
  final bool restaurantIsOpen;
  final VoidCallback? onTap;

  final GlobalKey _imageKey = GlobalKey();

  CompactFoodCard({
    super.key,
    required this.food,
    this.restaurantId,
    this.restaurantName,
    this.minOrderAmount,
    this.deliveryFee,
    this.restaurantIsOpen = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return HoverWrapper(
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 14, bottom: 10, top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 155, // Sabit yükseklik, daha büyük resimler
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                      child: SizedBox(
                        key: _imageKey,
                        width: double.infinity,
                        height: 155, // Resmin kutuyu tam doldurması için yüksekliği zorluyoruz
                        child: restaurantIsOpen
                            ? CachedNetworkImage(
                                imageUrl: food.imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[100],
                                  child: const Icon(Icons.fastfood, color: Colors.grey),
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
                                    imageUrl: food.imageUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[100],
                                      child: const Icon(Icons.fastfood, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    if (food.isCampaign || (food.oldPrice != null && food.oldPrice! > food.price))
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5D3EBC), // Getir Blue
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            food.oldPrice != null && food.oldPrice! > food.price
                                ? "-${((food.oldPrice! - food.price) / food.oldPrice! * 100).round()}%"
                                : "KAMPANYA",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                  ],
                ),
              ),
              // WHITE TITLE AREA
              Expanded(
                child: Container(
                  width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (restaurantName != null) ...[
                      Text(
                        restaurantName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      food.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textTitle,
                        letterSpacing: 0,
                      ),
                    ),

                  ],
                ),
              ),
              ),
              // CLEAN ACTION AREA
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${food.price} TMT",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF22B573),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (food.oldPrice != null && food.oldPrice! > food.price)
                          Text(
                            "${food.oldPrice} TMT",
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
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

                          // Snackbar kaldırıldı
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
                              // Snackbar kaldırıldı
                            },
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: restaurantIsOpen ? Colors.white : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: restaurantIsOpen ? const Color(0xFF22C55E) : Colors.grey.shade200, 
                            width: 1.5
                          ),
                        ),
                        child: Icon(
                          restaurantIsOpen ? Icons.add_rounded : Icons.lock_outline_rounded,
                          size: 20,
                          color: restaurantIsOpen ? const Color(0xFF5D3EBC) : Colors.grey.shade600,
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
}
