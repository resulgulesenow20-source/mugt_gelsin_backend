import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/pages/home/widgets/restaurant_grid.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';

class AllRestaurantsPage extends StatelessWidget {
  final List<Restaurant> restaurants;

  const AllRestaurantsPage({
    super.key,
    required this.restaurants,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final title = langProvider.selectedLang == 'TM' 
        ? 'Ähli Restoranlar' 
        : langProvider.selectedLang == 'TR' 
            ? 'Tüm Restoranlar' 
            : 'Все рестораны';

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          child: RestaurantGrid(restaurants: restaurants),
        ),
      ),
    );
  }
}
