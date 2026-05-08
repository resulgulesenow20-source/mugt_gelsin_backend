import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant_model.dart';

class FavoriteProvider with ChangeNotifier {
  final List<Restaurant> _favoriteRestaurants = [];
  final List<FoodWithRestaurant> _favoriteFoods = [];

  List<Restaurant> get favorites => _favoriteRestaurants;
  List<FoodWithRestaurant> get favoriteFoods => _favoriteFoods;

  FavoriteProvider() {
    _loadFromPrefs();
  }

  // âœ… HAFIZADAN YÜKLE
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Restoranlar
      final resString = prefs.getString('fav_restaurants');
      if (resString != null) {
        final List<dynamic> decoded = jsonDecode(resString);
        _favoriteRestaurants.clear();
        _favoriteRestaurants.addAll(decoded.map((json) => Restaurant.fromJson(json)).toList());
      }

      // Yemekler
      final foodString = prefs.getString('fav_foods');
      if (foodString != null) {
        final List<dynamic> decoded = jsonDecode(foodString);
        _favoriteFoods.clear();
        _favoriteFoods.addAll(decoded.map((json) => FoodWithRestaurant.fromJson(json)).toList());
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Favori yükleme hatası: $e");
    }
  }

  // âœ… HAFIZAYA KAYDET
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fav_restaurants', jsonEncode(_favoriteRestaurants.map((res) => res.toJson()).toList()));
      await prefs.setString('fav_foods', jsonEncode(_favoriteFoods.map((food) => food.toJson()).toList()));
    } catch (e) {
      debugPrint("Favori kaydetme hatası: $e");
    }
  }

  // RESTORAN FAVORİLEME
  void toggleFavorite(Restaurant restaurant) {
    final index = _favoriteRestaurants.indexWhere((res) => res.id == restaurant.id);
    if (index != -1) {
      _favoriteRestaurants.removeAt(index);
    } else {
      _favoriteRestaurants.add(restaurant);
    }
    _saveToPrefs();
    notifyListeners();
  }

  bool isExist(Restaurant restaurant) {
    return _favoriteRestaurants.any((res) => res.id == restaurant.id);
  }

  // ÜRÜN FAVORİLEME
  void toggleFoodFavorite(FoodWithRestaurant foodWithRes) {
    final index = _favoriteFoods.indexWhere((item) => item.food.id == foodWithRes.food.id);
    if (index != -1) {
      _favoriteFoods.removeAt(index);
    } else {
      _favoriteFoods.add(foodWithRes);
    }
    _saveToPrefs();
    notifyListeners();
  }

  bool isFoodFavorite(Food food) {
    return _favoriteFoods.any((item) => item.food.id == food.id || item.food.name == food.name);
  }
}
