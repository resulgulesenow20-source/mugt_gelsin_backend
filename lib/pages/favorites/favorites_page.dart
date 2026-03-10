import 'package:flutter/material.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:mugt_gelsin/utils/dummy_data.dart';
import 'package:mugt_gelsin/providers/favorite_provider.dart';
import 'package:mugt_gelsin/providers/language_provider.dart';
import 'package:mugt_gelsin/models/restaurant_model.dart';
import 'package:mugt_gelsin/pages/restaurant/restaurant_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            langProvider.translate('nav_favorites'),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.textPrimary,
            tabs: [
              Tab(text: langProvider.translate('restaurants')),
              Tab(text: langProvider.translate('products')),
            ],
          ),
        ),
        body: Consumer<FavoriteProvider>(
          builder: (context, favProvider, child) {
            return TabBarView(
              children: [
                // RESTORANLAR TAB
                favProvider.favorites.isEmpty
                    ? _buildEmptyState(context, langProvider.translate('no_fav_res'), Icons.storefront)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 110),
                        itemCount: favProvider.favorites.length,
                        itemBuilder: (context, index) {
                          final restaurant = favProvider.favorites[index];
                          return _buildFavoriteCard(context, favProvider, restaurant);
                        },
                      ),

                // ÜRÜNLER TAB
                favProvider.favoriteFoods.isEmpty
                    ? _buildEmptyState(context, langProvider.translate('no_fav_prod'), Icons.fastfood_outlined)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 110),
                        itemCount: favProvider.favoriteFoods.length,
                        itemBuilder: (context, index) {
                          final foodWithRes = favProvider.favoriteFoods[index];
                          return _buildFoodFavoriteCard(context, favProvider, foodWithRes);
                        },
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, FavoriteProvider provider, dynamic restaurant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(restaurant: restaurant),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                restaurant.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[100],
                  child: const Icon(Icons.storefront, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.textPrimary),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.deliveryTime,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.redAccent),
              onPressed: () => provider.toggleFavorite(restaurant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodFavoriteCard(BuildContext context, FavoriteProvider provider, FoodWithRestaurant item) {
    return GestureDetector(
      onTap: () async {
        final restaurant = dummyRestaurants.firstWhere(
          (res) => res.id == item.restaurantId,
          orElse: () => dummyRestaurants.first,
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(restaurant: restaurant),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                item.food.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[100],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "${item.food.price.toStringAsFixed(0)} TL",
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "• ${item.restaurantName}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.redAccent),
              onPressed: () => provider.toggleFoodFavorite(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F0FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            Provider.of<LanguageProvider>(context, listen: false).selectedLang == 'TR' 
              ? "Favorilerine eklediklerin burada görünecek."
              : Provider.of<LanguageProvider>(context, listen: false).selectedLang == 'TM'
                ? "Halanlaryňyz bu ýerde peýda bolar."
                : "Ваше избранное появится здесь.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
