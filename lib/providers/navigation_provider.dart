import 'package:flutter/material.dart';

enum HomeMode { normal, allProducts }

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 2; // Home is now at index 2
  HomeMode _homeMode = HomeMode.normal;
  int _resetHomeCounter = 0;
  String? _orderToTrack; // Takip edilecek aktif sipariÅŸ ID'si

  int get selectedIndex => _selectedIndex;
  HomeMode get homeMode => _homeMode;
  int get resetHomeCounter => _resetHomeCounter;
  String? get orderToTrack => _orderToTrack;

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

  // âœ… Ana sayfayÄ± sÄ±fÄ±rla (Arama ve modlarÄ± temizle)
  void triggerHomeReset() {
    _selectedIndex = 2;
    _homeMode = HomeMode.normal;
    _resetHomeCounter++;
    notifyListeners();
  }

  // Ã–ze geÃ§iÅŸ fonksiyonu: Ana sayfaya dÃ¶n ve tÃ¼m Ã¼rÃ¼nleri gÃ¶ster
  void switchToHomeWithAllProducts() {
    _selectedIndex = 2;
    _homeMode = HomeMode.allProducts;
    notifyListeners();
  }

  // Normal ana sayfaya dÃ¶n
  void switchToHomeNormal() {
    _selectedIndex = 2;
    _homeMode = HomeMode.normal;
    notifyListeners();
  }

  // âœ… SipariÅŸ takibine geÃ§ (Sekme 2 iÃ§inde aÃ§Ä±lacak)
  void switchToOrdersWithTracking(String orderId) {
    _selectedIndex = 1; // "SipariÅŸlerim" sekmesi
    _orderToTrack = orderId;
    notifyListeners();
  }

  // âœ… Takip sinyalini temizle
  void clearOrderTrackingSignal() {
    _orderToTrack = null;
  }
}
