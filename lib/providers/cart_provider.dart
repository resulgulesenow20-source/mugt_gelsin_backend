import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';

// âœ… SEPET Ã–ÄžESÄ° MODELÄ° (Bunu en Ã¼ste koyduk ki tanÄ±sÄ±n)
class CartItem {
  final Food food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  // âœ… Ã–ZEL LÄ°STE (Map kullanarak adet tutuyoruz)
  final Map<String, CartItem> _items = {};
  
  // âœ… RESTORAN BÄ°LGÄ°SÄ° (SipariÅŸi doÄŸru dÃ¼kkana gÃ¶ndermek iÃ§in)
  String? _restaurantId;
  String? _restaurantName;
  double _minOrderAmount = 50.0;

  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  double get minOrderAmount => _minOrderAmount;

  // âœ… DIÅžARIYA AÃ‡IK LÄ°STE (Hata veren 'items' burasÄ± iÅŸte)
  List<CartItem> get items => _items.values.toList();

  // âœ… SEPETE EKLEME
  void addToCart(Food food, {String? restaurantId, String? restaurantName, double? minOrderAmount}) {
    if (_items.isEmpty) {
      _restaurantId = restaurantId;
      _restaurantName = restaurantName;
      if (minOrderAmount != null) _minOrderAmount = minOrderAmount;
    }

    if (_items.containsKey(food.name)) {
      // ÃœrÃ¼n varsa adedi artÄ±r
      _items[food.name]!.quantity++;
    } else {
      // ÃœrÃ¼n yoksa yeni ekle
      _items[food.name] = CartItem(food: food);
    }
    notifyListeners(); // SayfayÄ± yeniletir
  }

  // âœ… SEPETTEN Ã‡IKARMA (Azaltma)
  void removeFromCart(Food food) {
    if (!_items.containsKey(food.name)) return;

    if (_items[food.name]!.quantity > 1) {
      _items[food.name]!.quantity--;
    } else {
      _items.remove(food.name);
    }
    notifyListeners();
  }

  // âœ… TOPLAM FÄ°YAT HESAPLAMA
  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.food.price * cartItem.quantity;
    });
    return total;
  }

  // âœ… SEPETÄ° SIFIRLA
  void clearCart() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    _minOrderAmount = 50.0;
    notifyListeners();
  }
}

