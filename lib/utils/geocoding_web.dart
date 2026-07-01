import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingHelper {
  static Future<Map<String, dynamic>?> getAddressFromCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1'
      );
      
      final response = await http.get(url, headers: {
        'User-Agent': 'mugut_gelsin_app_v1'
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null) {
          String city = address['city'] ?? address['town'] ?? address['village'] ?? '';
          String district = address['suburb'] ?? address['district'] ?? '';
          String street = address['road'] ?? '';
          
          String fullAddress = "$street${address['suburb'] != null ? ', ${address['suburb']}' : ''}${city.isNotEmpty ? ', $city' : ''}";
          if (fullAddress.startsWith(", ")) fullAddress = fullAddress.substring(2);

          return {
            'city': city,
            'district': district,
            'street': street,
            'fullAddress': fullAddress.isEmpty ? (data['display_name'] ?? "Seçilen Konum") : fullAddress,
          };
        }
      }
    } catch (e) {
      return {
        'fullAddress': "Adres alınamadı (Web)",
      };
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5'
      );
      
      final response = await http.get(url, headers: {
        'User-Agent': 'mugut_gelsin_app_v1'
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'lat': double.tryParse(item['lat'].toString()) ?? 0.0,
          'lon': double.tryParse(item['lon'].toString()) ?? 0.0,
          'displayName': item['display_name'] ?? query,
        }).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }
}
