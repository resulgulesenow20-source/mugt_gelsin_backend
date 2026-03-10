import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/restaurant_model.dart';

class ApiService {
  // --- PRODUCTION CONFIGURATION ---
  // Once deployed to Cloud Run, replace this with your Cloud Run URL
  static const String _productionBaseUrl = 'https://mugt-gelsin-backend-xyz.a.run.app';
  static const String _localFallbackUrl = 'http://172.20.10.2:5000';
  
  static String get baseUrl => kDebugMode ? _localFallbackUrl : _productionBaseUrl;

  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/restaurants'))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => _mapJsonToRestaurant(json, baseUrl)).toList();
      }
    } catch (e) {
      debugPrint('ApiService: fetchRestaurants hatası: $e');
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

  Restaurant _mapJsonToRestaurant(Map<String, dynamic> json, String activeBaseUrl) {
    String resolveImageUrl(String url) {
      if (url.isEmpty) return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400";
      if (url.startsWith('static/')) {
        return '$activeBaseUrl/$url';
      }
      return url;
    }

    return Restaurant(
      id: json['id']?.toString() ?? 'temp',
      name: json['name'] ?? 'Bilinmeyen Restoran',
      imageUrl: resolveImageUrl(json['imageUrl'] ?? ''),
      rating: json['rating']?.toString() ?? '0.0',
      deliveryTime: json['deliveryTime']?.toString() ?? '30-45dk',
      category: json['category'] ?? 'Diğer',
      minOrderAmount: json['minOrderAmount'] != null ? (json['minOrderAmount'] as num).toDouble() : 50.0,
      menu: (json['menu'] as List?)?.map<Food>((item) => Food(
        id: item['id']?.toString() ?? item['name'].toString().toLowerCase().replaceAll(' ', '_'),
        name: item['name'] ?? '',
        description: item['description'] ?? '',
        price: (item['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: resolveImageUrl(item['imageUrl'] ?? ''),
      )).toList() ?? [],
    );
  }
}
