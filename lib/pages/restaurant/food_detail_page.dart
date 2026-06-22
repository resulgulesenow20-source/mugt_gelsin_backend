import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mugut_gelsin/widgets/cart_dialogs.dart';

class FoodDetailPage extends StatefulWidget {
  final Food food;
  final String? restaurantId;
  final String? restaurantName;
  final double? minOrderAmount;
  final bool restaurantIsOpen;

  const FoodDetailPage({
    super.key,
    required this.food,
    this.restaurantId,
    this.restaurantName,
    this.minOrderAmount,
    this.restaurantIsOpen = true,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final TextEditingController _noteController = TextEditingController();

  Widget _buildSmartImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const Icon(Icons.error_outline),
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline),
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'food_${widget.food.id}_${widget.restaurantId}',
                child: _buildSmartImage(widget.food.imageUrl),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.food.name,
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "${widget.food.price} TMT",
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (widget.food.isCampaign && widget.food.oldPrice != null && widget.food.oldPrice! > widget.food.price) ...[
                        const SizedBox(width: 12),
                        Text(
                          "${widget.food.oldPrice} TMT",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "-${((widget.food.oldPrice! - widget.food.price) / widget.food.oldPrice! * 100).round()}%",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    lang.get('description'),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.food.description,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondary.withOpacity(0.5),
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Not Ekleme Bölümü
                  Text(
                    lang.get('order_note'),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: lang.selectedLang == 'TR' ? "Örn: Soğan olmasın, sosu bol olsun..." : "...",
                      hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.restaurantIsOpen)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  lang.get('shop_closed_warning'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.restaurantIsOpen
                    ? () {
                        final cartProvider = context.read<CartProvider>();
                        
                        if (cartProvider.canAddToCart(widget.restaurantId)) {
                          cartProvider.addToCart(
                            widget.food,
                            restaurantId: widget.restaurantId,
                            restaurantName: widget.restaurantName,
                            minOrderAmount: widget.minOrderAmount,
                            note: _noteController.text.isNotEmpty ? _noteController.text : null,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${widget.food.name} ${lang.get('added_to_cart')}"),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          CartDialogs.showDifferentRestaurantDialog(
                            context: context,
                            food: widget.food,
                            restaurantId: widget.restaurantId,
                            restaurantName: widget.restaurantName,
                            minOrderAmount: widget.minOrderAmount,
                            note: _noteController.text.isNotEmpty ? _noteController.text : null,
                            onSuccess: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(lang.get('cart_cleared_and_added')),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.restaurantIsOpen ? AppColors.primary : Colors.grey[300],
                  foregroundColor: widget.restaurantIsOpen ? Colors.white : Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Text(
                  widget.restaurantIsOpen
                      ? lang.get('add_to_cart').toUpperCase()
                      : lang.get('shop_closed').toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
