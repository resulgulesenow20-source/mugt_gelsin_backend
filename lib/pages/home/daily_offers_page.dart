import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/presentation/common/cards/food_card.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyOffersPage extends StatelessWidget {
  final List<Restaurant> restaurants;

  const DailyOffersPage({super.key, required this.restaurants});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    // Tüm restoranlardaki tüm menü öğelerini topla
    final List<FoodWithRestaurant> allFoods = [];
    for (var res in restaurants) {
      for (var food in res.menu) {
        if (food.isDailyOffer) {
          allFoods.add(FoodWithRestaurant(
            food: food,
            restaurantId: res.id,
            restaurantName: res.name,
            minOrderAmount: res.minOrderAmount,
            restaurantIsOpen: res.isOpen,
          ));
        }
      }
    }

    // İsme göre sırala veya karışık
    allFoods.shuffle();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Günün Teklifleri", 
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: Colors.black,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: allFoods.isEmpty
          ? Center(
              child: Text(
                langProvider.get('fav_empty_msg'), // Uygun bir boş mesaj
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: allFoods.length,
              itemBuilder: (context, index) {
                final item = allFoods[index];
                return FoodCard(
                  food: item.food,
                  restaurantId: item.restaurantId,
                  restaurantName: item.restaurantName,
                  minOrderAmount: item.minOrderAmount,
                  restaurantIsOpen: item.restaurantIsOpen,
                );
              },
            ),
    );
  }
}
