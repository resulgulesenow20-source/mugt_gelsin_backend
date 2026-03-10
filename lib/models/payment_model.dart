class PaymentCard {
  final String id;
  final String cardHolder;
  final String cardNumber; // Maskelenmiş (örn: **** **** **** 1234)
  final String expiryDate;
  final String cardType; // 'visa', 'mastercard', etc.
  bool isDefault;

  PaymentCard({
    required this.id,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
    this.cardType = 'visa',
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardHolder': cardHolder,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cardType': cardType,
      'isDefault': isDefault,
    };
  }

  factory PaymentCard.fromMap(Map<String, dynamic> map) {
    return PaymentCard(
      id: map['id'] ?? '',
      cardHolder: map['cardHolder'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      cardType: map['cardType'] ?? 'visa',
      isDefault: map['isDefault'] ?? false,
    );
  }
}
