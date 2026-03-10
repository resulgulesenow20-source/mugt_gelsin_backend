import 'package:flutter/material.dart';
import '../../../models/restaurant_model.dart';
import 'restaurant_card.dart';

class HorizontalRestaurantList extends StatelessWidget {
  final List<Restaurant> restaurants;

  const HorizontalRestaurantList({super.key, required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // Yana kayan kartların yüksekliği
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // SİHİR BURADA: Yana kaymayı sağlar
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160, // Her bir kartın genişliği
            margin: const EdgeInsets.only(right: 12),
            child: RestaurantCard(restaurant: restaurants[index]),
          );
        },
      ),
    );
  }
}
