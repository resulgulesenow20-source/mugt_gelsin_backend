import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/presentation/common/cards/compact_food_card.dart';

class HorizontalFoodList extends StatelessWidget {
  final List<FoodWithRestaurant> items;
  final Function(FoodWithRestaurant)? onItemTap;

  const HorizontalFoodList({super.key, required this.items, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260, // Increased height to allow larger, identical images
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
            minOrderAmount: item.minOrderAmount,
            restaurantIsOpen: item.restaurantIsOpen,
            onTap: onItemTap != null ? () => onItemTap!(item) : null,
          );
        },
      ),
    );
  }
}

