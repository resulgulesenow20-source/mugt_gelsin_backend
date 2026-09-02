import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mugut_gelsin/widgets/cart_dialogs.dart';
import 'package:mugut_gelsin/pages/cart/cart_page.dart';

class FoodDetailPage extends StatefulWidget {
  final Food food;
  final String? restaurantId;
  final String? restaurantName;
  final double? minOrderAmount;
  final double? deliveryFee;
  final bool restaurantIsOpen;
  final String? deliveryTime;

  const FoodDetailPage({
    super.key,
    required this.food,
    this.restaurantId,
    this.restaurantName,
    this.minOrderAmount,
    this.deliveryFee,
    this.restaurantIsOpen = true,
    this.deliveryTime,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final TextEditingController _noteController = TextEditingController();

  Widget _buildSmartImage(String url, {BoxFit fit = BoxFit.cover}) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        errorWidget: (context, url, error) => const Icon(Icons.error_outline),
      );
    } else {
      return Image.asset(
        url,
        fit: fit,
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
      backgroundColor: const Color(0xFFF6F6F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'food_${widget.food.id}_${widget.restaurantId}',
                      child: _buildSmartImage(widget.food.imageUrl, fit: BoxFit.cover),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.center_focus_strong, color: AppColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Text("1/1", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    if (widget.food.isCampaign)
                      Positioned(
                        bottom: 50,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B52F2),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text("En çok\ntercih edilen", textAlign: TextAlign.left, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, height: 1.1)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart, color: AppColors.primary),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
                    },
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0.0, -24.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.food.isCampaign) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF6ED),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars, color: Color(0xFFF3A638), size: 16),
                            const SizedBox(width: 6),
                            Text("Popüler", style: GoogleFonts.inter(color: const Color(0xFFF3A638), fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.restaurantName != null)
                                Text(
                                  widget.restaurantName!,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              Text(
                                widget.food.name,
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${widget.food.price} TMT",
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            if (widget.food.isCampaign && widget.food.oldPrice != null && widget.food.oldPrice! > widget.food.price) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5D3EBC),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "-${((widget.food.oldPrice! - widget.food.price) / widget.food.oldPrice! * 100).round()}%",
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${widget.food.oldPrice} TMT",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      widget.food.description.isNotEmpty 
                          ? widget.food.description 
                          : "İnce hamur üzerine özel baharatlarla hazırlanmış kıymalı harç. Fırından sıcak sıcak.",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                  ),
                                  child: const Icon(Icons.access_time, color: AppColors.primary, size: 16),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(fit: BoxFit.scaleDown, child: Text("Hazırlama süresi", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600))),
                                      FittedBox(fit: BoxFit.scaleDown, child: Text(widget.deliveryTime ?? "15-20 dk", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                  ),
                                  child: const Icon(Icons.restaurant_menu, color: AppColors.primary, size: 16),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(fit: BoxFit.scaleDown, child: Text("Porsiyon", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600))),
                                      FittedBox(fit: BoxFit.scaleDown, child: Text("1 adet", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                  ),
                                  child: const Icon(Icons.local_fire_department_outlined, color: AppColors.primary, size: 16),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(fit: BoxFit.scaleDown, child: Text("Kalori", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600))),
                                      FittedBox(fit: BoxFit.scaleDown, child: Text("310 kcal", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    Divider(color: Colors.grey.shade200, thickness: 1, height: 48),

                    // Düşündiriş
                    Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "Düşündiriş",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Taze soğan, maydanoz, limon ile servis edilir.\nİsteğe göre acılı veya acısız hazırlanır.",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Divider(color: Colors.grey.shade200, thickness: 1, height: 48),
                    
                    // Sargyt belgi
                    Row(
                      children: [
                        const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          lang.get('order_note'), // Veya sabit "Sargyt belgi"
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Options Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3EFFF), // Light purple bg
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.transparent),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.whatshot, color: AppColors.primary, size: 18),
                                const SizedBox(width: 8),
                                Text("Acılı", style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.eco_outlined, color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Text("Acısız", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.circle_outlined, color: Colors.amber, size: 18), // Limon icon substitution
                                const SizedBox(width: 8),
                                Text("Ekstra limon", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                        hintText: lang.selectedLang == 'TR' ? "Siparişiniz için not ekleyin..." : "Sargytnyz üçin bellik goşuñ...",
                        hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF6F6F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24), // pill shape
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 1, // Changed to 1 line for pill shape style shown in screenshot
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
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
                            deliveryFee: widget.deliveryFee,
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
                            deliveryFee: widget.deliveryFee,
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
