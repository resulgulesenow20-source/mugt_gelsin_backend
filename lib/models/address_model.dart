class Address {
  String id;
  String title; // Ev, İş, Okul gibi
  String city;
  String district; // İlçe
  String fullAddress;
  String type; // 'home', 'work', 'other'
  bool isDefault;

  Address({
    required this.id,
    required this.title,
    required this.city,
    required this.district,
    required this.fullAddress,
    this.type = 'home',
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'district': district,
      'fullAddress': fullAddress,
      'type': type,
      'isDefault': isDefault,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
      type: map['type'] ?? 'home',
      isDefault: map['isDefault'] ?? false,
    );
  }
}
