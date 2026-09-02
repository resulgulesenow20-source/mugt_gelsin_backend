import 'delivery_zone_model.dart';
import '../utils/distance_helper.dart';

// ✅ FOOD MODELİ
class Food {
  final String id; // ✅ Ürünleri tekil saptamak için ID eklendi
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isCampaign; // ✅ Kampanyalı mı
  final double? oldPrice; // ✅ Eski fiyatı
  final bool isDailyOffer; // ✅ Günün teklifi mi

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isCampaign = false,
    this.oldPrice,
    this.isDailyOffer = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'isCampaign': isCampaign,
    'oldPrice': oldPrice,
    'isDailyOffer': isDailyOffer,
  };

  factory Food.fromJson(Map<String, dynamic> json) => Food(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['imageUrl'] ?? '',
    isCampaign: json['isCampaign'] == true,
    oldPrice: (json['oldPrice'] as num?)?.toDouble(),
    isDailyOffer: json['isDailyOffer'] == true,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Food && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ✅ ÜRÜN VE RESTORAN İLİŞKİSİ MODELİ
class FoodWithRestaurant {
  final Food food;
  final String restaurantId;
  final String restaurantName;
  final double? minOrderAmount;
  final bool restaurantIsOpen;
  final String? deliveryTime;

  FoodWithRestaurant({
    required this.food,
    required this.restaurantId,
    required this.restaurantName,
    this.minOrderAmount,
    this.restaurantIsOpen = true,
    this.deliveryTime,
  });

  Map<String, dynamic> toJson() => {
    'food': food.toJson(),
    'restaurantId': restaurantId,
    'restaurantName': restaurantName,
    'minOrderAmount': minOrderAmount,
    'restaurantIsOpen': restaurantIsOpen,
    'deliveryTime': deliveryTime,
  };

  factory FoodWithRestaurant.fromJson(Map<String, dynamic> json) => FoodWithRestaurant(
    food: Food.fromJson(json['food']),
    restaurantId: json['restaurantId'] ?? '',
    restaurantName: json['restaurantName'] ?? '',
    minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
    restaurantIsOpen: json['restaurantIsOpen'] ?? true,
    deliveryTime: json['deliveryTime'],
  );
}

// ✅ RESTAURANT MODELİ
class Restaurant {
  final String id;
  final String? docId;
  final String name;
  final String imageUrl;
  final String rating;
  final String deliveryTime;
  final String category;
  final double minOrderAmount;
  bool isFavorite;
  final List<Food> menu;
  final bool isOpen;
  final String? openingTime;
  final String? closingTime;
  final double? latitude;
  final double? longitude;
  final String city;
  final String address;
  final List<String> deliveryDistricts;
  final List<DeliveryZone> deliveryZones;

  Restaurant({
    required this.id,
    this.docId,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.deliveryTime,
    required this.category,
    required this.minOrderAmount,
    required this.menu,
    this.isFavorite = false,
    this.isOpen = true,
    this.openingTime,
    this.closingTime,
    this.latitude,
    this.longitude,
    this.city = 'Aşgabat',
    this.address = '',
    this.deliveryDistricts = const [],
    this.deliveryZones = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'docId': docId,
    'name': name,
    'imageUrl': imageUrl,
    'rating': rating,
    'deliveryTime': deliveryTime,
    'category': category,
    'minOrderAmount': minOrderAmount,
    'isFavorite': isFavorite,
    'menu': menu.map((f) => f.toJson()).toList(),
    'isOpen': isOpen,
    'openingTime': openingTime,
    'closingTime': closingTime,
    'latitude': latitude,
    'longitude': longitude,
    'city': city,
    'address': address,
    'deliveryDistricts': deliveryDistricts,
    'deliveryZones': deliveryZones.map((z) => z.toMap()).toList(),
  };

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    String rawCity = json['city']?.toString() ?? json['region']?.toString() ?? json['Bölge']?.toString() ?? 'Aşkabat';
    String rawAddress = json['address']?.toString() ?? json['adres']?.toString() ?? rawCity;
    String rawCityLower = rawCity.toLowerCase().replaceAll('ş', 's').replaceAll('ý', 'y').replaceAll('ı', 'i');
    String rawAddressLower = rawAddress.toLowerCase().replaceAll('ş', 's').replaceAll('ý', 'y').replaceAll('ı', 'i');
    
    if (rawCityLower.contains('turkmenbasi') || rawCityLower.contains('turkmenbasy') || rawCityLower.contains('turkmenbashy') ||
        rawAddressLower.contains('turkmenbasi') || rawAddressLower.contains('turkmenbasy') || rawAddressLower.contains('turkmenbashy')) {
      rawCity = 'Türkmenbaşı';
    }

    return Restaurant(
      id: json['id'] ?? '',
      docId: json['docId'],
      name: json['name'] ?? json['isim'] ?? 'İsimsiz Restoran',
      imageUrl: json['imageUrl'] ?? '',
      rating: json['rating'] ?? '0.0',
      deliveryTime: json['deliveryTime'] ?? '',
      category: json['category'] ?? '',
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['isFavorite'] ?? false,
      menu: (json['menu'] as List<dynamic>?)?.map((f) => Food.fromJson(f)).toList() ?? [],
      isOpen: json['isOpen'] != false,
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      city: rawCity,
      address: rawAddress,
      deliveryDistricts: (json['deliveryDistricts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
  DeliveryZone? getActiveZone(double? userLat, double? userLng, {String? userRegion, String? userDistrict}) {
    if (deliveryZones.isEmpty) return null;
    
    bool hasValidUserCoords = userLat != null && userLng != null;
    bool hasValidResCoords = latitude != null && longitude != null;

    String targetRegion = (userDistrict != null && userDistrict.isNotEmpty) ? userDistrict : (userRegion ?? '');

    if ((!hasValidUserCoords || !hasValidResCoords) && targetRegion.isNotEmpty) {
      String normCurrent = targetRegion.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '');
      for (var zone in deliveryZones) {
        String normZone = zone.name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '');
        if (normZone.contains(normCurrent) || normCurrent.contains(normZone)) {
          return zone;
        }
      }
    }

    double uLat = userLat ?? 37.935;
    double uLng = userLng ?? 58.390;
    
    double resLat = latitude ?? (37.935 + (id.hashCode % 100) / 1000.0 - 0.05);
    double resLng = longitude ?? (58.390 + ((id.hashCode ~/ 100) % 100) / 1000.0 - 0.05);
    double distance = DistanceHelper.calculateDistance(uLat, uLng, resLat, resLng);

    for (var zone in deliveryZones) {
      if (zone.polygonPoints.isNotEmpty) {
        if (DistanceHelper.isPointInPolygon(uLat, uLng, zone.polygonPoints)) {
          return zone;
        }
      }
    }
    
    for (var zone in deliveryZones) {
      if (zone.polygonPoints.isEmpty) {
        if (distance <= zone.radius) {
          return zone;
        }
      }
    }
    
    // Fallback: Name matching if polygon/radius didn't match, or if coords were invalid earlier
    if (targetRegion.isNotEmpty) {
      String normCurrent = targetRegion.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '');
      for (var zone in deliveryZones) {
         String normZone = zone.name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '');
         if (normZone.contains(normCurrent) || normCurrent.contains(normZone)) {
           return zone;
         }
      }
    }

    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Restaurant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
