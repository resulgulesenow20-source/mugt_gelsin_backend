import 'dart:math';

/// İki GPS koordinatı arasındaki mesafeyi km cinsinden hesaplar.
/// Haversine formülü kullanır — ek bir kütüphane gerekmez.
class DistanceHelper {
  static const double _earthRadiusKm = 6371.0;

  /// [lat1], [lon1] → Kullanıcının konumu (adres koordinatları)
  /// [lat2], [lon2] → Restoranın koordinatları
  /// Geri dönüş değeri → km cinsinden mesafe (double)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _toRadians(double degree) {
    return degree * (pi / 180.0);
  }

  /// Mesafeyi kullanıcı dostu string'e çevirir
  /// Örn: 0.8 → "800 m" | 2.4 → "2.4 km"
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }
}
