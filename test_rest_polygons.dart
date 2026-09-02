import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final resBol = await http.get(Uri.parse('https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/Bolgeler'));
  final bolgeler = json.decode(resBol.body);

  if (bolgeler['documents'] != null) {
    for (var b in bolgeler['documents']) {
      final fields = b['fields'] ?? {};
      final shopId = fields['shop_id']?['stringValue'] ?? '';
      
      if (shopId == 'mugut_1839') {
        final name = fields['name']?['stringValue'] ?? '';
        final polygonPoints = fields['polygonPoints']?['arrayValue']?['values'] ?? [];
        print('Bolge for mugut_1839: $name, hasPolygon: ${polygonPoints.isNotEmpty}, pointsCount: ${polygonPoints.length}');
      }
    }
  }
}
