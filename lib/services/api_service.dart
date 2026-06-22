import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
import '../models/campaign_model.dart';

class ApiService {
  // --- CONFIGURATION ---
  static const bool _isLocal = false; // Yerel sunucunuz açıkken true yapabilirsiniz
  static const String _localBaseUrl = 'http://192.168.1.100:5000'; // BILGISAYARININ IP ADRESINI BURAYA YAZ (ipconfig ile bul)
  static const String _productionBaseUrl = 'https://mugut-gelsin-backend.onrender.com';
  
  static String get baseUrl => _isLocal ? _localBaseUrl : _productionBaseUrl;

  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      debugPrint('ApiService: Fetching restaurants and menus from Firestore...');
      
      // 1. Dükkanları Çek (Cache-First)
      QuerySnapshot shopSnapshot;
      try {
        shopSnapshot = await FirebaseFirestore.instance
            .collection('Dukkanlar')
            .get(const GetOptions(source: Source.cache));
        if (shopSnapshot.docs.isEmpty) {
          shopSnapshot = await FirebaseFirestore.instance
              .collection('Dukkanlar')
              .get(const GetOptions(source: Source.serverAndCache));
        }
      } catch (e) {
        shopSnapshot = await FirebaseFirestore.instance
            .collection('Dukkanlar')
            .get();
      }
          
      // 2. Menüleri Çek (Cache-First)
      QuerySnapshot menuSnapshot;
      try {
        menuSnapshot = await FirebaseFirestore.instance
            .collection('Menuler')
            .where('deleted', isEqualTo: false)
            .get(const GetOptions(source: Source.cache));
        if (menuSnapshot.docs.isEmpty) {
          menuSnapshot = await FirebaseFirestore.instance
              .collection('Menuler')
              .where('deleted', isEqualTo: false)
              .get(const GetOptions(source: Source.serverAndCache));
        }
      } catch (e) {
        menuSnapshot = await FirebaseFirestore.instance
            .collection('Menuler')
            .where('deleted', isEqualTo: false)
            .get();
      }

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
           var rawData = doc.data() as Map<String, dynamic>;
           var data = Map<String, dynamic>.from(rawData);
           String phone = data['phone']?.toString() ?? '';
           String mugutId = data['mugut_id']?.toString() ?? doc.id;
           
           // Web paneli hem phone hem mugut_id ile menü kaydedebiliyor
           List<Map<String, dynamic>> shopMenus = [];
           if (menuMap.containsKey(phone)) shopMenus.addAll(menuMap[phone]!);
           if (menuMap.containsKey(mugutId) && mugutId != phone) shopMenus.addAll(menuMap[mugutId]!);
           
           List<dynamic> existingList = [];
           if (data['menu'] is List) {
             existingList = List.from(data['menu']);
           } else if (data['Menü'] is List) {
             existingList = List.from(data['Menü']);
           }
           existingList.addAll(shopMenus);
           data['menu'] = existingList;

           return mapFirestoreToRestaurant(data, doc.id);
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService: fetchRestaurants Firestore error: $e');
    }
    return [];
  }

  Stream<List<Restaurant>> getRestaurantsStream() {
    return FirebaseFirestore.instance
        .collection('Dukkanlar')
        .snapshots()
        .asyncMap((shopSnapshot) async {
          QuerySnapshot menuSnapshot;
          try {
            // Try to load menus from cache first to avoid blocking on slow connections
            menuSnapshot = await FirebaseFirestore.instance
                .collection('Menuler')
                .where('deleted', isEqualTo: false)
                .get(const GetOptions(source: Source.cache));
            if (menuSnapshot.docs.isEmpty) {
              menuSnapshot = await FirebaseFirestore.instance
                  .collection('Menuler')
                  .where('deleted', isEqualTo: false)
                  .get(const GetOptions(source: Source.serverAndCache));
            }
          } catch (e) {
            menuSnapshot = await FirebaseFirestore.instance
                .collection('Menuler')
                .where('deleted', isEqualTo: false)
                .get();
          }

          Map<String, List<Map<String, dynamic>>> menuMap = {};
          for (var doc in menuSnapshot.docs) {
            var data = doc.data() as Map<String, dynamic>;
            String shopId = data['shop_id']?.toString() ?? '';
            if (shopId.isNotEmpty) {
              data['id'] = doc.id;
              if (!menuMap.containsKey(shopId)) {
                menuMap[shopId] = [];
              }
              menuMap[shopId]!.add(data);
            }
          }

          return shopSnapshot.docs.map((doc) {
             var rawData = doc.data();
             var data = Map<String, dynamic>.from(rawData);
             String phone = data['phone']?.toString() ?? '';
             String mugutId = data['mugut_id']?.toString() ?? doc.id;
             
             List<Map<String, dynamic>> shopMenus = [];
             if (menuMap.containsKey(phone)) shopMenus.addAll(menuMap[phone]!);
             if (menuMap.containsKey(mugutId) && mugutId != phone) shopMenus.addAll(menuMap[mugutId]!);
             
             List<dynamic> existingList = [];
             if (data['menu'] is List) {
               existingList = List.from(data['menu']);
             } else if (data['Menü'] is List) {
               existingList = List.from(data['Menü']);
             }
             existingList.addAll(shopMenus);
             data['menu'] = existingList;

             return mapFirestoreToRestaurant(data, doc.id);
          }).toList();
        });
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

  Restaurant mapFirestoreToRestaurant(Map<String, dynamic> data, String docId) {
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

          String foodImageUrl = item['image_url'] ?? item['imageUrl'] ?? item['Resim'] ?? '';
          if (foodImageUrl.startsWith('static/')) {
            foodImageUrl = '$baseUrl/$foodImageUrl';
          }

          return Food(
             id: item['id']?.toString() ?? item['name']?.toString().toLowerCase().replaceAll(' ', '_') ?? 'unknown_food',
             name: item['name'] ?? item['İsim'] ?? '',
             description: item['description'] ?? item['Açıklama'] ?? '',
             price: parsedPrice,
             imageUrl: foodImageUrl,
             isCampaign: item['isCampaign'] == true || item['is_campaign'] == true,
             oldPrice: double.tryParse(item['oldPrice']?.toString() ?? item['old_price']?.toString() ?? ''),
          );
        }
        return Food(id: 'unknown', name: 'Bilinmeyen Ürün', description: '', price: 0.0, imageUrl: '');
      }).toList();
    }

    // Görüntü URL'si (Panel logoUrl kullanıyor)
    String imageUrl = data['logoUrl'] ?? data['Resim'] ?? data['imageUrl'] ?? "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400";
    if (imageUrl.startsWith('static/')) {
        imageUrl = '$baseUrl/$imageUrl';
    }

    double parsedMinOrder = 50.0;
    if (data['minOrderAmount'] != null) {
      parsedMinOrder = double.tryParse(data['minOrderAmount'].toString()) ?? 50.0;
    } else if (data['Minimum Sipariş Tutarı'] != null) {
      parsedMinOrder = double.tryParse(data['Minimum Sipariş Tutarı'].toString()) ?? 50.0;
    }

    final String? openingTime = data['openingTime']?.toString() ?? data['acilisSaati']?.toString() ?? data['Açılış Saati']?.toString();
    final String? closingTime = data['closingTime']?.toString() ?? data['kapanisSaati']?.toString() ?? data['Kapanış Saati']?.toString();
    final bool databaseIsOpen = data['isOpen'] != false;
    final bool isOpen = _checkIsOpen(openingTime, closingTime, databaseIsOpen);

    final double? latitude = (data['latitude'] as num?)?.toDouble() ?? (data['lat'] as num?)?.toDouble();
    final double? longitude = (data['longitude'] as num?)?.toDouble() ?? (data['lng'] as num?)?.toDouble();

    final List<String> deliveryDistricts = (data['deliveryDistricts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return Restaurant(
      id: data['id']?.toString() ?? data['mugut_id']?.toString() ?? docId,
      docId: docId,
      name: data['restaurantName'] ?? data['name'] ?? data['İsim'] ?? 'Bilinmeyen Restoran',
      imageUrl: imageUrl,
      rating: data['rating']?.toString() ?? '0.0',
      deliveryTime: data['deliveryTime']?.toString() ?? '30-45dk',
      category: data['category'] ?? 'Genel',
      minOrderAmount: parsedMinOrder,
      menu: parsedMenu,
      isOpen: isOpen,
      openingTime: openingTime,
      closingTime: closingTime,
      latitude: latitude,
      longitude: longitude,
      deliveryDistricts: deliveryDistricts,
    );
  }

  bool _checkIsOpen(String? openingTime, String? closingTime, bool databaseIsOpen) {
    if (!databaseIsOpen) return false;
    if (openingTime == null || closingTime == null || openingTime.trim().isEmpty || closingTime.trim().isEmpty) {
      return true; // Default to open
    }

    try {
      final now = DateTime.now();
      final currentHour = now.hour;
      final currentMinute = now.minute;

      final openParts = openingTime.split(':');
      final closeParts = closingTime.split(':');
      if (openParts.length != 2 || closeParts.length != 2) return true;

      final openHour = int.parse(openParts[0].trim());
      final openMinute = int.parse(openParts[1].trim());

      final closeHour = int.parse(closeParts[0].trim());
      final closeMinute = int.parse(closeParts[1].trim());

      final nowMin = currentHour * 60 + currentMinute;
      final openMin = openHour * 60 + openMinute;
      final closeMin = closeHour * 60 + closeMinute;

      if (closeMin > openMin) {
        // Daytime range (e.g. 08:00 to 22:00)
        return nowMin >= openMin && nowMin < closeMin;
      } else {
        // Overnight range (e.g. 22:00 to 03:00)
        return nowMin >= openMin || nowMin < closeMin;
      }
    } catch (e) {
      debugPrint("Açılış/Kapanış saati ayrıştırma hatası: $e");
      return true;
    }
  }

  Future<List<Campaign>> fetchCampaigns() async {
    try {
      debugPrint('ApiService: Fetching active campaigns from Firestore...');
      final snapshot = await FirebaseFirestore.instance
          .collection('Kampanyalar')
          .where('isActive', isEqualTo: true)
          .get();
          
      return snapshot.docs.map((doc) => Campaign.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('ApiService: fetchCampaigns error: $e');
      return [];
    }
  }
}
