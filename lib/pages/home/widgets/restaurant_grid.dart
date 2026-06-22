import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/presentation/common/cards/restaurant_card.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/models/campaign_model.dart';

class RestaurantGrid extends StatefulWidget {
  final List<Restaurant> restaurants;
  final List<Campaign> campaigns;

  const RestaurantGrid({
    super.key, 
    required this.restaurants,
    this.campaigns = const [],
  });

  @override
  State<RestaurantGrid> createState() => _RestaurantGridState();
}

class _RestaurantGridState extends State<RestaurantGrid> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.restaurants.isEmpty) {
      return const SizedBox();
    }

    // Clamp current page to avoid out of bounds when list updates
    if (_currentPage >= widget.restaurants.length) {
      _currentPage = 0;
    }

    return Column(
      children: [
        SizedBox(
          height: 310, // Artırılmış yükseklik (kampanya şeridi dahil)
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: widget.restaurants.length,
            itemBuilder: (context, index) {
              final res = widget.restaurants[index];
              final isSelected = _currentPage == index;

              return AnimatedScale(
                scale: isSelected ? 1.0 : 0.93,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.7,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: RestaurantCard(
                      res: res,
                      imageHeight: 150, // Resim daha büyük ve çekici
                      campaigns: widget.campaigns,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.restaurants.length > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.restaurants.length, (index) {
              final isSelected = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: isSelected ? 20 : 6,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}



