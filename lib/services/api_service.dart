import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class ApiService {
  // --- PRODUCTION CONFIGURATION ---
  // Once deployed to Cloud Run, replace this with your Cloud Run URL
  static const String _productionBaseUrl = 'https://mugt-gelsin-backend.onrender.com';
  
  static String get baseUrl => _productionBaseUrl;

  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      debugPrint('ApiService: Fetching restaurants from Firestore...');
      
      // 'restaurants' veya 'Restoranlar' koleksiyonlarına bakabiliriz.
      // Python koduna göre, masaüstü uygulaması 'Restoranlar' koleksiyonunu kullanıyor gibi görünüyor,
      // ancak emin olmak için her iki koleksiyon yapısını da yönetebilecek bir fallback sistemi kurmalıyız.
      // Şimdilik standart Firestore sorgumuzu yapıyoruz.
      
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Restoranlar').get();
      
      if (snapshot.docs.isNotEmpty) {
        debugPrint('ApiService: ${snapshot.docs.length} restaurants found in "Restoranlar".');
        return snapshot.docs.map((doc) => _mapFirestoreToRestaurant(doc.data() as Map<String, dynamic>, doc.id)).toList();
      } else {
        debugPrint('ApiService: "Restoranlar" is empty, trying "restaurants"...');
        snapshot = await FirebaseFirestore.instance.collection('restaurants').get();
        return snapshot.docs.map((doc) => _mapFirestoreToRestaurant(doc.data() as Map<String, dynamic>, doc.id)).toList();
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
    
    // Menü alanlarını dönüştürme: Hem 'menu' hem de Türkçe isimlendirme olan 'Menü' kontrolü
    var menuData = data['menu'] ?? data['Menü'];
    if (menuData is List) {
      parsedMenu = menuData.map<Food>((item) {
        if (item is Map) {
          return Food(
             id: item['id']?.toString() ?? item['name']?.toString().toLowerCase().replaceAll(' ', '_') ?? 'unknown_food',
             name: item['name'] ?? item['İsim'] ?? '',
             description: item['description'] ?? item['Açıklama'] ?? '',
             price: (item['price'] ?? item['Fiyat'] as num?)?.toDouble() ?? 0.0,
             imageUrl: item['imageUrl'] ?? item['Resim'] ?? '',
          );
        }
        return Food(id: 'unknown', name: 'Bilinmeyen Ürün', description: '', price: 0.0, imageUrl: '');
      }).toList();
    }

    // Görüntü URL'si
    String imageUrl = data['imageUrl'] ?? data['Resim'] ?? "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400";
    if (imageUrl.startsWith('static/')) {
        imageUrl = '$_productionBaseUrl/$imageUrl';
    }

    return Restaurant(
      id: data['id']?.toString() ?? docId,
      name: data['name'] ?? data['İsim'] ?? 'Bilinmeyen Restoran',
      imageUrl: imageUrl,
      rating: data['rating']?.toString() ?? data['Puan']?.toString() ?? '0.0',
      deliveryTime: data['deliveryTime']?.toString() ?? data['Teslimat Süresi']?.toString() ?? '30-45dk',
      category: data['category'] ?? data['Kategori'] ?? 'Genel',
      minOrderAmount: (data['minOrderAmount'] ?? data['Minimum Sipariş Tutarı'] as num?)?.toDouble() ?? 50.0,
      menu: parsedMenu,
    );
  }
}
