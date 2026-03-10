class Coupon {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discountAmount;
  final DateTime expiryDate;
  final bool isUsed;
  final String type; // 'percentage' or 'amount'

  Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountAmount,
    required this.expiryDate,
    this.isUsed = false,
    this.type = 'amount',
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isValid => !isUsed && !isExpired;

  factory Coupon.fromMap(Map<String, dynamic> map, String id) {
    return Coupon(
      id: id,
      code: map['code'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      expiryDate: (map['expiryDate'] as DateTime),
      isUsed: map['isUsed'] ?? false,
      type: map['type'] ?? 'amount',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'discountAmount': discountAmount,
      'expiryDate': expiryDate,
      'isUsed': isUsed,
      'type': type,
    };
  }
}
