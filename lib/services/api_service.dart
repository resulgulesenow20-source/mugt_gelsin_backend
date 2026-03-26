import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class ApiService {
  // --- PRODUCTION CONFIGURATION ---
  // Once deployed to Cloud Run, replace this with your Cloud Run URL
  static const String _productionBaseUrl = 'https://mugut-gelsin-backend.onrender.com';
  
  static String get baseUrl => _productionBaseUrl;

  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      debugPrint('ApiService: Fetching restaurants from Firestore...');
      
      // 'restaurants' veya 'Restoranlar' koleksiyonlarÄ±na bakabiliriz.
      // Python koduna gÃ¶re, masaÃ¼stÃ¼ uygulamasÄ± 'Restoranlar' koleksiyonunu kullanÄ±yor gibi gÃ¶rÃ¼nÃ¼yor,
      // ancak emin olmak iÃ§in her iki koleksiyon yapÄ±sÄ±nÄ± da yÃ¶netebilecek bir fallback sistemi kurmalÄ±yÄ±z.
      // Åžimdilik standart Firestore sorgumuzu yapÄ±yoruz.
      
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
      debugPrint('ApiService: SipariÅŸ gÃ¶nderilemedi: $e');
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
      debugPrint("Destek mesajÄ± gÃ¶nderme hatasÄ±: $e");
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
      debugPrint("Destek mesajlarÄ± Ã§ekme hatasÄ±: $e");
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
      debugPrint("YorumlarÄ± Ã§ekme hatasÄ±: $e");
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
      debugPrint("Yorum gÃ¶nderme hatasÄ±: $e");
      return false;
    }
  }

  Restaurant _mapFirestoreToRestaurant(Map<String, dynamic> data, String docId) {
    // Firestore'da menÃ¼ (yemekler) genellikle bir liste olarak tutulur.
    List<Food> parsedMenu = [];
    
    // MenÃ¼ alanlarÄ±nÄ± dÃ¶nÃ¼ÅŸtÃ¼rme: Hem 'menu' hem de TÃ¼rkÃ§e isimlendirme olan 'MenÃ¼' kontrolÃ¼
    var menuData = data['menu'] ?? data['MenÃ¼'];
    if (menuData is List) {
      parsedMenu = menuData.map<Food>((item) {
        if (item is Map) {
          return Food(
             id: item['id']?.toString() ?? item['name']?.toString().toLowerCase().replaceAll(' ', '_') ?? 'unknown_food',
             name: item['name'] ?? item['Ä°sim'] ?? '',
             description: item['description'] ?? item['AÃ§Ä±klama'] ?? '',
             price: (item['price'] ?? item['Fiyat'] as num?)?.toDouble() ?? 0.0,
             imageUrl: item['imageUrl'] ?? item['Resim'] ?? '',
          );
        }
        return Food(id: 'unknown', name: 'Bilinmeyen ÃœrÃ¼n', description: '', price: 0.0, imageUrl: '');
      }).toList();
    }

    // GÃ¶rÃ¼ntÃ¼ URL'si
    String imageUrl = data['imageUrl'] ?? data['Resim'] ?? "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400";
    if (imageUrl.startsWith('static/')) {
        imageUrl = '$_productionBaseUrl/$imageUrl';
    }

    return Restaurant(
      id: data['id']?.toString() ?? docId,
      name: data['name'] ?? data['Ä°sim'] ?? 'Bilinmeyen Restoran',
      imageUrl: imageUrl,
      rating: data['rating']?.toString() ?? data['Puan']?.toString() ?? '0.0',
      deliveryTime: data['deliveryTime']?.toString() ?? data['Teslimat SÃ¼resi']?.toString() ?? '30-45dk',
      category: data['category'] ?? data['Kategori'] ?? 'Genel',
      minOrderAmount: (data['minOrderAmount'] ?? data['Minimum SipariÅŸ TutarÄ±'] as num?)?.toDouble() ?? 50.0,
      menu: parsedMenu,
    );
  }
}

