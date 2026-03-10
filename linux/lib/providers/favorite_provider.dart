import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';

class FavoriteProvider with ChangeNotifier {
  final List<Restaurant> _favoriteRestaurants = [];

  // ✅ BU SATIR EKSİKTİ: Dışarıdaki sayfalar 'favorites' diyerek bu listeye ulaşacak
  List<Restaurant> get favorites => _favoriteRestaurants;

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
}
