import 'package:geolocator/geolocator.dart';
import '../models/restaurant_model.dart';
import '../models/address_model.dart';

class DistanceCalculator {
  /// Calculates the distance between two coordinates in kilometers
  static double calculateDistanceKm(double startLat, double startLng, double endLat, double endLng) {
    // Geolocator.distanceBetween returns distance in meters
    double distanceInMeters = Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
    return distanceInMeters / 1000.0;
  }

  /// Filters and sorts a list of restaurants based on distance from the user's address.
  /// Restaurants without valid coordinates are optionally included but placed at the end or hidden.
  static List<Restaurant> filterAndSortRestaurants({
    required List<Restaurant> restaurants,
    required Address? userAddress,
    double maxDistanceKm = 50.0,
    bool hideWithoutCoordinates = false,
  }) {
    // Eğer kullanıcının adresi yoksa veya koordinatları yoksa, varsayılan olarak Aşgabat merkezini (37.935, 58.390) kabul et
    final double userLat = userAddress?.latitude ?? 37.935;
    final double userLng = userAddress?.longitude ?? 58.390;

    // Create a list to hold restaurants with their calculated distances
    List<Map<String, dynamic>> restaurantsWithDistance = [];

    for (var restaurant in restaurants) {
      if (restaurant.latitude != null && restaurant.longitude != null) {
        double distance = calculateDistanceKm(
          userLat,
          userLng,
          restaurant.latitude!,
          restaurant.longitude!,
        );

        // Filter out if it's too far
        if (distance <= maxDistanceKm) {
          restaurantsWithDistance.add({
            'restaurant': restaurant,
            'distance': distance,
          });
        }
      } else {
        // If restaurant has no coordinates, we can include them with a very large distance
        // so they appear at the very bottom, OR we can completely hide them.
        if (!hideWithoutCoordinates) {
          restaurantsWithDistance.add({
            'restaurant': restaurant,
            'distance': 99999.0, // Push to bottom
          });
        }
      }
    }

    // Sort by distance (closest first)
    restaurantsWithDistance.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    // Map back to List<Restaurant>
    return restaurantsWithDistance.map((e) => e['restaurant'] as Restaurant).toList();
  }
}
