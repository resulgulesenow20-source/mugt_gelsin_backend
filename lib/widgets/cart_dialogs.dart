import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';

class CartDialogs {
  static Future<void> showDifferentRestaurantDialog({
    required BuildContext context,
    required Food food,
    required String? restaurantId,
    required String? restaurantName,
    required double? minOrderAmount,
    String? note,
    VoidCallback? onSuccess,
  }) async {
    final cartProvider = context.read<CartProvider>();
    final lang = context.read<LanguageProvider>();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          lang.get('different_res_title'),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          lang.get('different_res_msg')
              .replaceAll('{res}', cartProvider.restaurantName ?? "")
              .replaceAll('{newRes}', restaurantName ?? ""),
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              lang.get('give_up'),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.clearAndAddToCart(
                food,
                restaurantId: restaurantId,
                restaurantName: restaurantName,
                minOrderAmount: minOrderAmount,
                note: note,
              );
              Navigator.pop(context);
              if (onSuccess != null) onSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              lang.get('clear_cart_and_add'),
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
