import 'package:flutter/material.dart';
import 'package:mugt_gelsin/models/restaurant_model.dart';
import 'package:mugt_gelsin/presentation/common/cards/restaurant_card.dart';

class RestaurantGrid extends StatelessWidget {
  final List<Restaurant> restaurants;

  const RestaurantGrid({super.key, required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: restaurants.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 215, // Sabit yükseklik belirleyerek alttaki fazla boşluğu alıyoruz
      ),
      itemBuilder: (context, index) {
        final res = restaurants[index];
        return RestaurantCard(res: res);
      },
    );
  }
}


