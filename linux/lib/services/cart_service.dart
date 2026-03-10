import 'package:flutter/material.dart';
import '../models/restaurant_model.dart'; // Food modelinin olduğu yer

class CartItem {
  final Food food; // 'String' yerine 'food' nesnesini tutuyoruz
  int quantity;

  CartItem({required this.food, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  // Yemek ismini (String) anahtar olarak kullanan Map
  final Map<String, CartItem> _items = {};

  // Dışarıdan sepet listesine erişim
  List<CartItem> get items => _items.values.toList();

  // Sepete ekleme
  void addToCart(Food food) {
    if (_items.containsKey(food.name)) {
      // Varsa miktarını artır
      _items[food.name]!.quantity++;
    } else {
      // Yoksa yeni ekle
      _items[food.name] = CartItem(food: food);
    }
    notifyListeners(); // 👈 Sayfayı anında yeniler!
  }

  // Sepetten çıkarma
  void removeFromCart(Food food) {
    if (_items.containsKey(food.name)) {
      if (_items[food.name]!.quantity > 1) {
        _items[food.name]!.quantity--;
      } else {
        _items.remove(food.name);
      }
      notifyListeners(); // 👈 Sayfayı anında yeniler!
    }
  }

  // Toplam fiyat hesaplama
  double get totalPrice {
    double total = 0;
    _items.forEach((key, item) {
      total += item.food.price * item.quantity;
    });
    return total;
  }

  // Toplam ürün sayısı (Sepet ikonundaki rakam için)
  int get totalItemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
