import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/pages/home/widgets/restaurant_grid.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/pages/home/widgets/home_empty_state.dart';

class CategoryRestaurantsPage extends StatefulWidget {
  final String categoryName;
  final List<Restaurant> allRestaurants;

  const CategoryRestaurantsPage({
    super.key,
    required this.categoryName,
    required this.allRestaurants,
  });

  @override
  State<CategoryRestaurantsPage> createState() => _CategoryRestaurantsPageState();
}

class _CategoryRestaurantsPageState extends State<CategoryRestaurantsPage> {
  List<Restaurant> _filteredRestaurants = [];

  @override
  void initState() {
    super.initState();
    _filterData();
  }

  String _normalizeString(String text) {
    return text.toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ç', 'c');
  }

  void _filterData() {
    final query = _normalizeString(widget.categoryName);
    
    if (widget.categoryName.toLowerCase() == "hepsi") {
      _filteredRestaurants = List.from(widget.allRestaurants);
    } else {
      _filteredRestaurants = widget.allRestaurants.where((res) {
        final catMatch = _normalizeString(res.category).contains(query);
        final foodMatch = res.menu.any((food) => 
          _normalizeString(food.name).contains(query) || 
          _normalizeString(food.description).contains(query)
        );
        return catMatch || foodMatch;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: _filteredRestaurants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "Bu kategoride restoran bulunamadı.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Geri Dön", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  RestaurantGrid(restaurants: _filteredRestaurants),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
