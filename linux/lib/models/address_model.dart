class Address {
  String id;
  String title; // Ev, İş, Okul gibi
  String city;
  String district; // İlçe
  String fullAddress;

  Address({
    required this.id,
    required this.title,
    required this.city,
    required this.district,
    required this.fullAddress,
  });
}
