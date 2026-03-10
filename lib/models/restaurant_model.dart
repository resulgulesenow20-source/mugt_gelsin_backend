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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Restaurant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
