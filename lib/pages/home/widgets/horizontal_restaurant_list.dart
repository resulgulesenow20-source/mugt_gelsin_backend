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
      height: isCompact ? 275 : 320, // Height adjusts based on compactness (increased for campaigns)
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Yana kaymayı sağlar
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Shadow breathing room
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          return Container(
            width: isCompact ? 160 : 250, // Width adjusts based on compactness
            margin: const EdgeInsets.only(right: 16),
            child: RestaurantCard(
              res: restaurants[index],
              isCompact: isCompact, // Pass down compactness
              imageHeight: isCompact ? 100 : 120, // Image height adjusts
              campaigns: campaigns,
            ),
          );
        },
      ),
    );
  }
}

