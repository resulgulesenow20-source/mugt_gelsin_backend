import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class ApiService {
  // --- CONFIGURATION ---
  static const bool _isLocal = true; // Geliştirme sırasında true yapın
  static const String _localBaseUrl = 'http://localhost:5000';
  static const String _productionBaseUrl = 'https://mugut-gelsin-backend.onrender.com';
  
  static String get baseUrl => _isLocal ? _localBaseUrl : _productionBaseUrl;

  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      debugPrint('ApiService: Fetching restaurants and menus from Firestore...');
      
      // 1. Dükkanları Çek
      QuerySnapshot shopSnapshot = await FirebaseFirestore.instance
          .collection('Dukkanlar')
          .get();
          
      // 2. Menüleri Çek (Sadece silinmemiş olanlar)
      QuerySnapshot menuSnapshot = await FirebaseFirestore.instance
          .collection('Menuler')
          .where('deleted', isEqualTo: false)
          .get();

      // Menüleri shop_id'ye göre grupla
      Map<String, List<Map<String, dynamic>>> menuMap = {};
      for (var doc in menuSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String shopId = data['shop_id']?.toString() ?? '';
        if (shopId.isNotEmpty) {
          data['id'] = doc.id; // Ürün ID'si
          if (!menuMap.containsKey(shopId)) {
            menuMap[shopId] = [];
          }
          menuMap[shopId]!.add(data);
        }
      }
      
      if (shopSnapshot.docs.isNotEmpty) {
        debugPrint('ApiService: ${shopSnapshot.docs.length} restaurants found.');
        return shopSnapshot.docs.map((doc) {
           var data = doc.data() as Map<String, dynamic>;
           String phone = data['phone']?.toString() ?? '';
           String mugutId = data['mugut_id']?.toString() ?? doc.id;
           
           // Web paneli hem phone hem mugut_id ile menü kaydedebiliyor
           List<Map<String, dynamic>> shopMenus = [];
           if (menuMap.containsKey(phone)) shopMenus.addAll(menuMap[phone]!);
           if (menuMap.containsKey(mugutId) && mugutId != phone) shopMenus.addAll(menuMap[mugutId]!);
           
           // Eğer panelden çekilen menü varsa, veritabanına ekle
           List existing = data['menu'] ?? data['Menü'] ?? [];
           existing.addAll(shopMenus);
           data['menu'] = existing;

           return _mapFirestoreToRestaurant(data, doc.id);
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService: fetchRestaurants Firestore error: $e');
    }
    return [];
  }

  Future<bool> placeOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('ApiService: Sipariş gönderilemedi: $e');
      return false;
    }
  }

  Future<bool> sendSupportMessage(Map<String, dynamic> messageData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/support/message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(messageData),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Destek mesajı gönderme hatası: $e");
      return false;
    }
  }

  Future<List<dynamic>> getSupportMessages(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/support/messages/$uid'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Destek mesajları çekme hatası: $e");
    }
    return [];
  }

  Future<List<dynamic>> fetchReviews(String shopId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reviews/$shopId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Yorumları çekme hatası: $e");
    }
    return [];
  }

  Future<bool> submitReview(String shopId, Map<String, dynamic> reviewData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/reviews/$shopId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reviewData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Yorum gönderme hatası: $e");
      return false;
    }
  }

  Restaurant _mapFirestoreToRestaurant(Map<String, dynamic> data, String docId) {
    // Firestore'da menü (yemekler) genellikle bir liste olarak tutulur.
    List<Food> parsedMenu = [];
    
    var menuData = data['menu'];
    if (menuData is List) {
      parsedMenu = menuData.map<Food>((item) {
        if (item is Map) {
          // Fiyatı string ya da numara olabilme ihtimaline karşı güvenli parse
          double parsedPrice = 0.0;
          if (item['price'] != null) {
            parsedPrice = double.tryParse(item['price'].toString()) ?? 0.0;
          } else if (item['Fiyat'] != null) {
            parsedPrice = double.tryParse(item['Fiyat'].toString()) ?? 0.0;
          }

          return Food(
             id: item['id']?.toString() ?? item['name']?.toString().toLowerCase().replaceAll(' ', '_') ?? 'unknown_food',
             name: item['name'] ?? item['İsim'] ?? '',
             description: item['description'] ?? item['Açıklama'] ?? '',
             price: parsedPrice,
             imageUrl: item['image_url'] ?? item['imageUrl'] ?? item['Resim'] ?? '',
          );
        }
        return Food(id: 'unknown', name: 'Bilinmeyen Ürün', description: '', price: 0.0, imageUrl: '');
      }).toList();
    }

    // Görüntü URL'si (Panel logoUrl kullanıyor)
    String imageUrl = data['logoUrl'] ?? data['Resim'] ?? data['imageUrl'] ?? "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400";
    if (imageUrl.startsWith('static/')) {
        imageUrl = '$_localBaseUrl/$imageUrl';
    }

    return Restaurant(
      id: data['id']?.toString() ?? data['mugut_id']?.toString() ?? docId,
      name: data['restaurantName'] ?? data['name'] ?? data['İsim'] ?? 'Bilinmeyen Restoran',
      imageUrl: imageUrl,
      rating: data['rating']?.toString() ?? '0.0',
      deliveryTime: data['deliveryTime']?.toString() ?? '30-45dk',
      category: data['category'] ?? 'Genel',
      minOrderAmount: (data['minOrderAmount'] ?? data['Minimum Sipariş Tutarı'] as num?)?.toDouble() ?? 50.0,
      menu: parsedMenu,
    );
  }
}
