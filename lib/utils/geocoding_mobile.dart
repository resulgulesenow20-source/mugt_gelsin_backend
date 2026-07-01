import 'package:geocoding/geocoding.dart';

class GeocodingHelper {
  static Future<Map<String, dynamic>?> getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        String city = place.administrativeArea ?? ''; // Örn: İstanbul
        String district = place.subAdministrativeArea ?? place.locality ?? ''; // Örn: Kadıköy
        String street = place.street ?? place.thoroughfare ?? ''; // Örn: Bağdat Cad.
        
        String fullAddress = "${place.street ?? ''}${place.subLocality != null ? ', ${place.subLocality}' : ''}${place.locality != null ? ', ${place.locality}' : ''}";
        if (fullAddress.startsWith(", ")) fullAddress = fullAddress.substring(2);

        return {
          'city': city,
          'district': district,
          'street': street,
          'fullAddress': fullAddress.isEmpty ? "Seçilen Konum" : fullAddress,
        };
      }
    } catch (e) {
      return {
        'fullAddress': "Adres alınamadı (Mobil)",
      };
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        return locations.map((loc) => {
          'lat': loc.latitude,
          'lon': loc.longitude,
          'displayName': query, // geocoding doesn't return full address text for locationFromAddress easily, so we just use the query or we can reverse geocode it, but usually query is fine for mobile search result tap.
        }).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }
}
