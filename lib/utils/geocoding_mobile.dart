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
}
