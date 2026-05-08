class Address {
  final String id;
  final String title;
  final String city;
  final String district;
  final String street;
  final String buildingNo;
  final String floor;
  final String doorNo;
  final String fullAddress;
  final String type;
  bool isDefault;
  final double? latitude;
  final double? longitude;

  Address({
    required this.id,
    required this.title,
    required this.city,
    required this.district,
    this.street = '',
    this.buildingNo = '',
    this.floor = '',
    this.doorNo = '',
    required this.fullAddress,
    this.type = 'home',
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'district': district,
      'street': street,
      'buildingNo': buildingNo,
      'floor': floor,
      'doorNo': doorNo,
      'fullAddress': fullAddress,
      'type': type,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      street: map['street'] ?? '',
      buildingNo: map['buildingNo'] ?? '',
      floor: map['floor'] ?? '',
      doorNo: map['doorNo'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
      type: map['type'] ?? 'home',
      isDefault: map['isDefault'] ?? false,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}
