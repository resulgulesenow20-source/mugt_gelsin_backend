import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/pages/cart/checkout_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/pages/home/widgets/logo_mark_widget.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final cartItems = cartProvider.items;

    return Scaffold(
      backgroundColor: const Color(0xFF2B0F6B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B0F6B),
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const LogoMarkWidget(size: 36, color: Color(0xFF6BCC5E)),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mugut",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "gelsin",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFFD500), size: 28),
              onPressed: () => _showClearCartDialog(context, cartProvider, langProvider),
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF9F7FC), // Very light purple background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: cartItems.isEmpty
            ? _buildEmptyCart(context, langProvider)
            : Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "Sebedim",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF130A2A),
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                            cartProvider.removeFromCart(item);
                          },
                          child: _buildCartItemCard(cartProvider, item, langProvider),
                        );
                      },
                    ),
                  ),
                  _buildOrderSummary(context, cartProvider, langProvider),
                ],
              ),
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: item.food.imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 90,
                height: 90,
                color: Colors.grey[100],
                child: const Icon(Icons.fastfood, color: Colors.grey, size: 24),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF130A2A)),
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.food.price.toStringAsFixed(2)} TMT",
                  style: const TextStyle(
                    color: Color(0xFF2B0F6B),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (item.note != null && item.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "${langProvider.get('order_note')}: ${item.note}",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuantityBtn(
                        icon: Icons.remove,
                        color: const Color(0xFF2B0F6B),
                        onPressed: () => cartProvider.removeFromCart(item),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "${item.quantity}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF130A2A)),
                        ),
                      ),
                      _buildQuantityBtn(
                        icon: Icons.add,
                        color: const Color(0xFF2B0F6B),
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
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, LanguageProvider lang) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 260,
                          height: 260,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF6F4FA),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(Icons.shopping_basket_rounded, size: 80, color: const Color(0xFF2B0F6B).withOpacity(0.2)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Sebediňiz entek boş!",
                          style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2B0F6B)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Häzir lezzetli tagamlaryň birini saýlaň\nwe sebediňizi doldurmaga başlaň.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Inter', color: Colors.grey.shade600, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => context.read<NavigationProvider>().switchToHomeWithAllProducts(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD500),
                              foregroundColor: const Color(0xFF2B0F6B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text("Sargyt etmäge başla", style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 120, top: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF0F7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD500), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Şu gün nämä isleyär?",
                                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2B0F6B)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Bir tagam saýla, keýpiňi göter.",
                                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFF2B0F6B)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart, LanguageProvider lang) {
    final double subtotal = cart.totalPrice;
    final double minOrderAmount = cart.minOrderAmount; 
    final bool isBelowMinOrder = subtotal < minOrderAmount;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Jemi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF130A2A))),
              Text("${subtotal.toStringAsFixed(2)} TMT", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF130A2A))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Color(0xFFEEEEEE), thickness: 1, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Umumy baha", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF130A2A))),
              Text(
                "${subtotal.toStringAsFixed(2)} TMT",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF130A2A),
                ),
              ),
            ],
          ),
          if (isBelowMinOrder) ...[
            const SizedBox(height: 16),
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
                          .replaceAll('{rem}', (minOrderAmount - subtotal).toStringAsFixed(2)),
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isBelowMinOrder
                  ? null
                  : () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (context) => const CheckoutPage()),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD500),
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: const Color(0xFF130A2A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sargydy tamamla",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

