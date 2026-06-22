import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/pages/cart/checkout_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final cartItems = cartProvider.items;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          langProvider.translate('nav_cart'),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _showClearCartDialog(context, cartProvider, langProvider),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context, langProvider)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      return Dismissible(
                        key: Key(item.food.name),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.redAccent.withOpacity(0.1),
                          child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        ),
                        onDismissed: (direction) {
                          cartProvider.removeFromCart(item); // ÃœrÃ¼nÃ¼ tamamen sildik (quantity gÃ¶zetmeksizin silmek iÃ§in dÃ¶ngÃ¼ye gerek yok, Map'ten siliyoruz)
                        },
                        child: _buildCartItemCard(cartProvider, item, langProvider),
                      );
                    },
                  ),
                ),
                _buildOrderSummary(context, cartProvider, langProvider),
              ],
            ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate('clear_cart')),
        content: Text(lang.translate('clear_cart_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('cancel'), style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
            },
            child: Text(lang.translate('clear'), style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartProvider cartProvider, dynamic item, LanguageProvider langProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.food.imageUrl,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  width: 65,
                  height: 65,
                  color: Colors.grey[100],
                  child: const Icon(Icons.fastfood, color: Colors.grey, size: 20),
                ),
              ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.food.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  "${item.food.price.toStringAsFixed(2)} TMT",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (item.note != null && item.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      "${langProvider.get('order_note')}: ${item.note}",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${(item.food.price * item.quantity).toStringAsFixed(2)} TMT",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildQuantityBtn(
                            icon: Icons.remove,
                            onPressed: () => cartProvider.removeFromCart(item),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "${item.quantity}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          _buildQuantityBtn(
                            icon: Icons.add,
                            onPressed: () => cartProvider.addToCart(
                              item.food, 
                              note: item.note,
                              restaurantId: cartProvider.restaurantId,
                              restaurantName: cartProvider.restaurantName,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              size: 80,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            lang.get('empty_cart_msg'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            lang.get('empty_cart_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.read<NavigationProvider>().switchToHomeWithAllProducts(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Text(lang.get('start_shopping'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart, LanguageProvider lang) {
    const double deliveryFee = 15.0;
    const double serviceFee = 5.0;
    final double minOrderAmount = cart.minOrderAmount; 
    final double total = cart.totalPrice + deliveryFee + serviceFee;
    final bool isBelowMinOrder = cart.totalPrice < minOrderAmount;
    final double remainingAmount = minOrderAmount - cart.totalPrice;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow(lang.get('subtotal'), "${cart.totalPrice.toStringAsFixed(2)} TMT"),
          _buildSummaryRow(lang.get('delivery_fee'), "${deliveryFee.toStringAsFixed(2)} TMT"),
          _buildSummaryRow(lang.get('service_fee'), "${serviceFee.toStringAsFixed(2)} TMT"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lang.get('total_price'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "${total.toStringAsFixed(2)} TMT",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (isBelowMinOrder) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lang.get('min_order_warning')
                          .replaceAll('{min}', minOrderAmount.toStringAsFixed(0))
                          .replaceAll('{rem}', remainingAmount.toStringAsFixed(2)),
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: isBelowMinOrder
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CheckoutPage()),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isBelowMinOrder ? Colors.grey.shade400 : AppColors.secondary,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lang.translate('complete_order'),
                    style: TextStyle(
                      color: isBelowMinOrder ? Colors.grey.shade600 : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isBelowMinOrder ? Colors.grey.shade600 : AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

