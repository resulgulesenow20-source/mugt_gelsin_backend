import 'package:flutter/material.dart';
import 'package:mugt_gelsin/presentation/common/cards/food_card.dart';
import 'package:mugt_gelsin/models/restaurant_model.dart';
import 'package:mugt_gelsin/pages/home/widgets/review_section.dart';
import 'package:provider/provider.dart';
import 'package:mugt_gelsin/providers/cart_provider.dart';
import 'package:mugt_gelsin/pages/cart/cart_page.dart';
import 'package:mugt_gelsin/providers/favorite_provider.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  // Resim yükleme ve hata yönetimi fonksiyonu
  Widget _buildSmartImage(String url, {double? width, double? height}) {
    final cleanUrl = url.trim();
    if (cleanUrl.startsWith('http')) {
      return Image.network(
        cleanUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _errorWidget("Link Bozuk"),
      );
    } else {
      return Image.asset(
        cleanUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorWidget("DOSYA YOK"),
      );
    }
  }

  Widget _errorWidget(String message) {
    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 30),
          Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String user, String rating, String comment) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(rating, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // ✅ FAVORİ BUTONU EKLENDİ
          Consumer<FavoriteProvider>(
            builder: (context, provider, child) {
              final isFav = provider.isExist(widget.restaurant);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.black,
                ),
                onPressed: () => provider.toggleFavorite(widget.restaurant),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    // ✅ BAĞLANTI BURADA: Sepet ikonuna basınca CartPage açılır
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );
                  },
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      context.watch<CartProvider>().items.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSmartImage(
              widget.restaurant.imageUrl,
              width: double.infinity,
              height: 220,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(
                        " ${widget.restaurant.rating} • ${widget.restaurant.deliveryTime}",
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ReviewSection(restaurantId: widget.restaurant.id),
                  const SizedBox(height: 32),
                  const Text(
                    "Popüler Menüler",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...widget.restaurant.menu
                      .map(
                        (food) => FoodCard(
                          food: food,
                          restaurantId: widget.restaurant.id,
                          restaurantName: widget.restaurant.name,
                          minOrderAmount: widget.restaurant.minOrderAmount,
                        ),
                      )
                      ,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
