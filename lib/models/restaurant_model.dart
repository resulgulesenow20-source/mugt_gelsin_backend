// ✅ FOOD MODELİ
class Food {
  final String id; // ✅ Ürünleri tekil saptamak için ID eklendi
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
  };

  factory Food.fromJson(Map<String, dynamic> json) => Food(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['imageUrl'] ?? '',
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

  FoodWithRestaurant({
    required this.food,
    required this.restaurantId,
    required this.restaurantName,
  });

  Map<String, dynamic> toJson() => {
    'food': food.toJson(),
    'restaurantId': restaurantId,
    'restaurantName': restaurantName,
  };

  factory FoodWithRestaurant.fromJson(Map<String, dynamic> json) => FoodWithRestaurant(
    food: Food.fromJson(json['food']),
    restaurantId: json['restaurantId'] ?? '',
    restaurantName: json['restaurantName'] ?? '',
  );
}

// ✅ RESTAURANT MODELİ
class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final String rating;
  final String deliveryTime;
  final String category;
  final double minOrderAmount;
  bool isFavorite;
  final List<Food> menu;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.deliveryTime,
    required this.category,
    required this.minOrderAmount,
    required this.menu,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'rating': rating,
    'deliveryTime': deliveryTime,
    'category': category,
    'minOrderAmount': minOrderAmount,
    'isFavorite': isFavorite,
    'menu': menu.map((f) => f.toJson()).toList(),
  };

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    rating: json['rating'] ?? '0.0',
    deliveryTime: json['deliveryTime'] ?? '',
    category: json['category'] ?? '',
    minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
    isFavorite: json['isFavorite'] ?? false,
    menu: (json['menu'] as List<dynamic>?)?.map((f) => Food.fromJson(f)).toList() ?? [],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Restaurant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
