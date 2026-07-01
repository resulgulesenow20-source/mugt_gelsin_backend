import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/presentation/common/cards/restaurant_card.dart';
import 'package:mugut_gelsin/models/campaign_model.dart';

class HorizontalRestaurantList extends StatelessWidget {
  final List<Restaurant> restaurants;
  final bool isCompact;
  final List<Campaign> campaigns;

  const HorizontalRestaurantList({
    super.key, 
    required this.restaurants,
    this.isCompact = true, // Defaults to compact
    this.campaigns = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isCompact ? 235 : 240, // Height increased to fix bottom text clipping
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Yana kaymayı sağlar
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Shadow breathing room
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          return Container(
            width: 290, // Wider cards to match visual 2
            margin: const EdgeInsets.only(right: 16),
            child: RestaurantCard(
              res: restaurants[index],
              isCompact: isCompact, // Keep compact layout for texts if needed, but size is bigger
              imageHeight: 150, // Image height adjusts
              campaigns: campaigns,
            ),
          );
        },
      ),
    );
  }
}

