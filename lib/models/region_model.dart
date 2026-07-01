class Region {
  final String id;
  final String name; // e.g., Aşkabat
  final List<String> districts; // e.g., [Bagtyýarlyk, Berkararlyk]

  Region({
    required this.id,
    required this.name,
    required this.districts,
  });

  factory Region.fromMap(String id, Map<String, dynamic> map) {
    return Region(
      id: id,
      name: map['name'] ?? id,
      districts: List<String>.from(map['districts'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'districts': districts,
    };
  }
}
