import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/pages/restaurant/restaurant_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/favorite_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/presentation/common/widgets/hover_wrapper.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant res;
  final double? imageHeight;
  final bool isCompact;

  const RestaurantCard({
    super.key,
    required this.res,
    this.imageHeight,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
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
                    child: Image.network(
                      res.imageUrl,
                      height: imageHeight ?? 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: imageHeight ?? 130,
                        color: AppColors.surfaceSubtle,
                        child: const Icon(Icons.fastfood_rounded, color: AppColors.textTertiary, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _buildRatingBadge(res.rating),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Consumer<FavoriteProvider>(
                      builder: (context, provider, child) {
                        final isFav = provider.isExist(res);
                        return GestureDetector(
                          onTap: () => provider.toggleFavorite(res),
                          child: _buildFavoriteButton(isFav),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(isCompact ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      res.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: isCompact ? 16 : 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.restaurant_menu_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            res.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          res.deliveryTime,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "FRESH",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
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
    );
  }

  Widget _buildRatingBadge(dynamic rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: 2),
          Text(
            "$rating",
            style: GoogleFonts.outfit(
              fontSize: 12, 
              fontWeight: FontWeight.w800,
              color: AppColors.textTitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(bool isFavorite) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        size: 18,
        color: isFavorite ? Colors.red : Colors.grey,
      ),
    );
  }
}

