class DeliveryZone {
  final String id;
  final String name;
  final double radius;
  final String deliveryTime;
  final double minOrder;
  final String shopId;
  final List<Map<String, double>> polygonPoints;

  DeliveryZone({
    required this.id,
    required this.name,
    required this.radius,
    required this.deliveryTime,
    required this.minOrder,
    required this.shopId,
    this.polygonPoints = const [],
  });

  factory DeliveryZone.fromMap(Map<String, dynamic> map, String docId) {
    List<Map<String, double>> parsedPoints = [];
    if (map['polygonPoints'] != null && map['polygonPoints'] is List) {
      for (var point in map['polygonPoints']) {
        if (point is Map) {
          parsedPoints.add({
            'lat': double.tryParse(point['lat']?.toString() ?? '0') ?? 0.0,
            'lng': double.tryParse(point['lng']?.toString() ?? '0') ?? 0.0,
          });
        }
      }
    }

    return DeliveryZone(
      id: docId,
      name: map['name']?.toString() ?? '',
      radius: double.tryParse(map['radius']?.toString() ?? '') ?? 3.0,
      deliveryTime: map['deliveryTime']?.toString() ?? '',
      minOrder: double.tryParse(map['minOrder']?.toString() ?? '') ?? 100.0,
      shopId: map['shop_id']?.toString() ?? '',
      polygonPoints: parsedPoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'radius': radius,
      'deliveryTime': deliveryTime,
      'minOrder': minOrder,
      'shop_id': shopId,
      'polygonPoints': polygonPoints,
    };
  }
}
