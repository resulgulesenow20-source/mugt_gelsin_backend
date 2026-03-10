// ✅ FOOD MODELİ
class Food {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Food({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  // ✅ ÖNEMLİ: Provider'ın ürünleri tanıyabilmesi için bu iki metodu eklemelisin
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Food && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

// ✅ RESTAURANT MODELİ
class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final String rating;
  final String deliveryTime;
  final String category;
  bool isFavorite;
  final List<Food> menu;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.deliveryTime,
    required this.category,
    required this.menu,
    this.isFavorite = false,
  });
}
