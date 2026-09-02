import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ SEPET ÖĞESİ MODELİ
class CartItem {
  final Food food;
  int quantity;
  String? note;

  CartItem({required this.food, this.quantity = 1, this.note});

  Map<String, dynamic> toJson() => {
    'food': food.toJson(),
    'quantity': quantity,
    'note': note,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    food: Food.fromJson(json['food']),
    quantity: json['quantity'] ?? 1,
    note: json['note'],
  );
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  
  String? _restaurantId;
  String? _restaurantName;
  double _minOrderAmount = 50.0;
  double _deliveryFee = 0.0;

  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  double get minOrderAmount => _minOrderAmount;
  double get deliveryFee => _deliveryFee;
  List<CartItem> get items => _items.values.toList();

  CartProvider() {
    _loadFromPrefs();
  }

  // ✅ HAFIZADAN YÜKLE
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('cart_data');
      if (cartString != null) {
        final Map<String, dynamic> cartData = jsonDecode(cartString);
        
        _restaurantId = cartData['restaurantId'];
        _restaurantName = cartData['restaurantName'];
        _minOrderAmount = cartData['minOrderAmount'] ?? 50.0;
        _deliveryFee = cartData['deliveryFee'] ?? 0.0;
        
        final List<dynamic> itemsList = cartData['items'] ?? [];
        _items.clear();
        for (var itemJson in itemsList) {
          final item = CartItem.fromJson(itemJson);
          final String itemKey = "${item.food.id}_${item.note ?? ""}";
          _items[itemKey] = item;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Sepet yükleme hatası: $e");
    }
  }

  // ✅ HAFIZAYA KAYDET
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = {
        'restaurantId': _restaurantId,
        'restaurantName': _restaurantName,
        'minOrderAmount': _minOrderAmount,
        'deliveryFee': _deliveryFee,
        'items': _items.values.map((item) => item.toJson()).toList(),
      };
      await prefs.setString('cart_data', jsonEncode(cartData));
    } catch (e) {
      debugPrint("Sepet kaydetme hatası: $e");
    }
  }

  bool canAddToCart(String? newRestaurantId) {
    if (_items.isEmpty) return true;
    return _restaurantId == newRestaurantId;
  }

  void clearAndAddToCart(Food food, {String? restaurantId, String? restaurantName, double? minOrderAmount, double? deliveryFee, String? note}) {
    clearCart();
    addToCart(food, 
      restaurantId: restaurantId, 
      restaurantName: restaurantName, 
      minOrderAmount: minOrderAmount,
        deliveryFee: deliveryFee, 
      note: note
    );
  }

  void addToCart(Food food, {String? restaurantId, String? restaurantName, double? minOrderAmount, double? deliveryFee, String? note}) {
    if (_items.isEmpty) {
      _restaurantId = restaurantId;
      _restaurantName = restaurantName;
      if (minOrderAmount != null) _minOrderAmount = minOrderAmount;
      if (deliveryFee != null) _deliveryFee = deliveryFee;
    } else if (_restaurantId != restaurantId) {
      // Different restaurant - in a strict implementation we might throw here, 
      // but we'll rely on the UI calling canAddToCart first.
      debugPrint("Farklı restoran ürünü eklenmeye çalışıldı. Mevcut: $_restaurantId, Yeni: $restaurantId");
      return; 
    }

    final String itemKey = "${food.id}_${note ?? ""}";

    if (_items.containsKey(itemKey)) {
      _items[itemKey]!.quantity++;
    } else {
      _items[itemKey] = CartItem(food: food, note: note);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    final String itemKey = "${item.food.id}_${item.note ?? ""}";
    
    if (!_items.containsKey(itemKey)) return;

    if (_items[itemKey]!.quantity > 1) {
      _items[itemKey]!.quantity--;
    } else {
      _items.remove(itemKey);
    }
    _saveToPrefs();
    notifyListeners();
  }

  double get totalPrice {
    double total = 0.0;
    _items.forEach((final key, final cartItem) {
      total += cartItem.food.price * cartItem.quantity;
    });
    return total;
  }

  void clearCart() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    _minOrderAmount = 50.0;
    _deliveryFee = 0.0;
    _saveToPrefs();
    notifyListeners();
  }
}
