// ✅ FOOD MODELİ
class Food {
  final String id; // ✅ Ürünleri tekil saptamak için ID eklendi
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isCampaign; // ✅ Kampanyalı mı
  final double? oldPrice; // ✅ Eski fiyatı

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isCampaign = false,
    this.oldPrice,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'isCampaign': isCampaign,
    'oldPrice': oldPrice,
  };

  factory Food.fromJson(Map<String, dynamic> json) => Food(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['imageUrl'] ?? '',
    isCampaign: json['isCampaign'] == true,
    oldPrice: (json['oldPrice'] as num?)?.toDouble(),
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

  FoodWithRestaurant({
    required this.food,
    required this.restaurantId,
    required this.restaurantName,
    this.minOrderAmount,
    this.restaurantIsOpen = true,
  });

  Map<String, dynamic> toJson() => {
    'food': food.toJson(),
    'restaurantId': restaurantId,
    'restaurantName': restaurantName,
    'minOrderAmount': minOrderAmount,
    'restaurantIsOpen': restaurantIsOpen,
  };

  factory FoodWithRestaurant.fromJson(Map<String, dynamic> json) => FoodWithRestaurant(
    food: Food.fromJson(json['food']),
    restaurantId: json['restaurantId'] ?? '',
    restaurantName: json['restaurantName'] ?? '',
    minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
    restaurantIsOpen: json['restaurantIsOpen'] ?? true,
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
  final List<String> deliveryDistricts;

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
    this.city = 'Aşkabat',
    this.deliveryDistricts = const [],
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
    'deliveryDistricts': deliveryDistricts,
  };

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'] ?? '',
    docId: json['docId'],
    name: json['name'] ?? '',
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
    city: json['city']?.toString() ?? json['region']?.toString() ?? json['Bölge']?.toString() ?? 'Aşkabat',
    deliveryDistricts: (json['deliveryDistricts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Restaurant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
