import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  preparing,
  onWay,
  delivered,
  cancelled
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({required this.name, required this.quantity, required this.price});

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String shopId;
  final String shopName;
  final double totalPrice;
  final OrderStatus status;
  final List<OrderItem> items;
  final String deliveryAddress;
  final String? courierName;
  final DateTime timestamp;
  final bool isRated;

  OrderModel({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.totalPrice,
    required this.status,
    required this.items,
    required this.deliveryAddress,
    this.courierName,
    required this.timestamp,
    this.isRated = false,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      shopId: data['shop_id'] ?? '',
      shopName: data['shop_name'] ?? '',
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: _statusFromString(data['status'] ?? 'pending'),
      items: (data['items'] as List? ?? [])
          .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      courierName: data['courier_name'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRated: data['isRated'] ?? false,
    );
  }

  static OrderStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'hazırlanıyor':
      case 'preparing':
        return OrderStatus.preparing;
      case 'yolda':
      case 'on_the_way':
      case 'onway':
        return OrderStatus.onWay;
      case 'iptal_edildi':
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'teslim_edildi':
      case 'teslim edildi':
      case 'delivered':
      case 'tamamlandi':
      case 'tamamlandı':
        return OrderStatus.delivered;
      case 'onaylanıyor':
      case 'onay bekliyor':
      case 'onay_bekliyor':
        return OrderStatus.pending;
      default:
        return OrderStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      case OrderStatus.preparing: return "Hazırlanıyor";
      case OrderStatus.onWay: return "Yolda";
      case OrderStatus.delivered: return "Teslim Edildi";
      case OrderStatus.cancelled: return "İptal Edildi";
      default: return "Onay Bekliyor";
    }
  }
}
