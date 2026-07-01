import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/presentation/common/cards/food_card.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';

class AllFoodsPage extends StatelessWidget {
  final List<FoodWithRestaurant> foods;

  const AllFoodsPage({
    super.key,
    required this.foods,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final title = langProvider.selectedLang == 'TM' 
        ? 'Ähli Tagamlar' 
        : langProvider.selectedLang == 'TR' 
            ? 'Tüm Yemekler' 
            : 'Все блюда';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // Full width items
          childAspectRatio: 3.5, // Make them look like cards
          mainAxisSpacing: 8,
        ),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final item = foods[index];
          
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
