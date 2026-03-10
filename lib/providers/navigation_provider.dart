import 'package:flutter/material.dart';

enum HomeMode { normal, allProducts }

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;
  HomeMode _homeMode = HomeMode.normal;

  int _resetHomeCounter = 0;

  int get selectedIndex => _selectedIndex;
  HomeMode get homeMode => _homeMode;
  int get resetHomeCounter => _resetHomeCounter;

  // Animation trigger
  Function(GlobalKey)? runAddToCartAnimation;

  void setAddToCartAnimationFunction(Function(GlobalKey) runAnimation) {
    runAddToCartAnimation = runAnimation;
  }

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setHomeMode(HomeMode mode) {
    _homeMode = mode;
    notifyListeners();
  }

  // ✅ Ana sayfayı sıfırla (Arama ve modları temizle)
  void triggerHomeReset() {
    _selectedIndex = 0;
    _homeMode = HomeMode.normal;
    _resetHomeCounter++;
    notifyListeners();
  }

  // Özel geçiş fonksiyonu: Ana sayfaya dön ve tüm ürünleri göster
  void switchToHomeWithAllProducts() {
    _selectedIndex = 0;
    _homeMode = HomeMode.allProducts;
    notifyListeners();
  }

  // Normal ana sayfaya dön
  void switchToHomeNormal() {
    _selectedIndex = 0;
    _homeMode = HomeMode.normal;
    notifyListeners();
  }
}
