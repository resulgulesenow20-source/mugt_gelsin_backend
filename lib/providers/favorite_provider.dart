import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';

class FavoriteProvider with ChangeNotifier {
  final List<Restaurant> _favoriteRestaurants = [];
  final List<FoodWithRestaurant> _favoriteFoods = [];

  List<Restaurant> get favorites => _favoriteRestaurants;
  List<FoodWithRestaurant> get favoriteFoods => _favoriteFoods;

  // RESTORAN FAVORİLEME
  void toggleFavorite(Restaurant restaurant) {
    if (_favoriteRestaurants.contains(restaurant)) {
      _favoriteRestaurants.remove(restaurant);
    } else {
      _favoriteRestaurants.add(restaurant);
    }
    notifyListeners();
  }

  bool isExist(Restaurant restaurant) {
    return _favoriteRestaurants.contains(restaurant);
  }

  // ÜRÜN FAVORİLEME
  void toggleFoodFavorite(FoodWithRestaurant foodWithRes) {
    final index = _favoriteFoods.indexWhere((item) => item.food.id == foodWithRes.food.id);
    if (index != -1) {
      _favoriteFoods.removeAt(index);
    } else {
      _favoriteFoods.add(foodWithRes);
    }
    notifyListeners();
  }

  bool isFoodFavorite(Food food) {
    return _favoriteFoods.any((item) => item.food.id == food.id || item.food.name == food.name);
  }
}
