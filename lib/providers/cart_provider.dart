import 'package:flutter/material.dart';
import 'package:mugt_gelsin/models/restaurant_model.dart';

// ✅ SEPET ÖĞESİ MODELİ (Bunu en üste koyduk ki tanısın)
class CartItem {
  final Food food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  // ✅ ÖZEL LİSTE (Map kullanarak adet tutuyoruz)
  final Map<String, CartItem> _items = {};
  
  // ✅ RESTORAN BİLGİSİ (Siparişi doğru dükkana göndermek için)
  String? _restaurantId;
  String? _restaurantName;
  double _minOrderAmount = 50.0;

  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  double get minOrderAmount => _minOrderAmount;

  // ✅ DIŞARIYA AÇIK LİSTE (Hata veren 'items' burası işte)
  List<CartItem> get items => _items.values.toList();

  // ✅ SEPETE EKLEME
  void addToCart(Food food, {String? restaurantId, String? restaurantName, double? minOrderAmount}) {
    if (_items.isEmpty) {
      _restaurantId = restaurantId;
      _restaurantName = restaurantName;
      if (minOrderAmount != null) _minOrderAmount = minOrderAmount;
    }

    if (_items.containsKey(food.name)) {
      // Ürün varsa adedi artır
      _items[food.name]!.quantity++;
    } else {
      // Ürün yoksa yeni ekle
      _items[food.name] = CartItem(food: food);
    }
    notifyListeners(); // Sayfayı yeniletir
  }

  // ✅ SEPETTEN ÇIKARMA (Azaltma)
  void removeFromCart(Food food) {
    if (!_items.containsKey(food.name)) return;

    if (_items[food.name]!.quantity > 1) {
      _items[food.name]!.quantity--;
    } else {
      _items.remove(food.name);
    }
    notifyListeners();
  }

  // ✅ TOPLAM FİYAT HESAPLAMA
  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.food.price * cartItem.quantity;
    });
    return total;
  }

  // ✅ SEPETİ SIFIRLA
  void clearCart() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    _minOrderAmount = 50.0;
    notifyListeners();
  }
}
