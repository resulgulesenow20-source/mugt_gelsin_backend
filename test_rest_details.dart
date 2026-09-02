import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final resBol = await http.get(Uri.parse('https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/Bolgeler'));
  final bolgeler = json.decode(resBol.body);

  if (bolgeler['documents'] != null) {
    for (var b in bolgeler['documents']) {
      final fields = b['fields'] ?? {};
      final name = fields['name']?['stringValue'] ?? '';
      final shopId = fields['shop_id']?['stringValue'] ?? '';
      
      final minOrderMap = fields['minOrder'] ?? {};
      final deliveryTimeMap = fields['deliveryTime'] ?? {};
      
      print('Bolge: $name (shop: $shopId) - minOrder: $minOrderMap, deliveryTime: $deliveryTimeMap');
    }
  }
}
