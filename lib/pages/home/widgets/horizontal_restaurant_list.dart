import 'package:flutter/material.dart';
import 'package:mugt_gelsin/models/restaurant_model.dart';
import 'package:mugt_gelsin/presentation/common/cards/restaurant_card.dart';

class HorizontalRestaurantList extends StatelessWidget {
  final List<Restaurant> restaurants;

  const HorizontalRestaurantList({super.key, required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210, // Increased height to prevent overflow
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // SİHİR BURADA: Yana kaymayı sağlar
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add vertical padding for shadow
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160, // Increased width for larger cards
            margin: const EdgeInsets.only(right: 16), // Increased margin
            child: RestaurantCard(
              res: restaurants[index],
              isCompact: true,
              imageHeight: 100, // Adjusted image height
            ),
          );
        },
      ),
    );
  }
}
