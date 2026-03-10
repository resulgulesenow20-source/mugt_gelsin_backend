import 'package:flutter/material.dart';
import 'package:mugt_gelsin/models/restaurant_model.dart';
import 'package:mugt_gelsin/presentation/common/cards/compact_food_card.dart';

class HorizontalFoodList extends StatelessWidget {
  final List<FoodWithRestaurant> items;
  final Function(FoodWithRestaurant)? onItemTap;

  const HorizontalFoodList({super.key, required this.items, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return CompactFoodCard(
            food: item.food,
            restaurantId: item.restaurantId,
            restaurantName: item.restaurantName,
            onTap: onItemTap != null ? () => onItemTap!(item) : null,
          );
        },
      ),
    );
  }
}
