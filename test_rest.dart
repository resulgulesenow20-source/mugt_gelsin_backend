import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final resDuk = await http.get(Uri.parse('https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/Dukkanlar'));
  print('Dukkanlar code: ${resDuk.statusCode}');
  final dukkanlar = json.decode(resDuk.body);
  
  final resBol = await http.get(Uri.parse('https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/Bolgeler'));
  print('Bolgeler code: ${resBol.statusCode}');
  final bolgeler = json.decode(resBol.body);

  if (dukkanlar['documents'] != null) {
    for (var d in dukkanlar['documents']) {
      final fields = d['fields'] ?? {};
      final name = fields['name']?['stringValue'] ?? '';
      final phone = fields['phone']?['stringValue'] ?? '';
      final mugutId = fields['mugut_id']?['stringValue'] ?? '';
      print('Dukkan: ${d['name'].split('/').last} - $name, phone: $phone, mugut_id: $mugutId');
    }
  }

  if (bolgeler['documents'] != null) {
    for (var b in bolgeler['documents']) {
      final fields = b['fields'] ?? {};
      final name = fields['name']?['stringValue'] ?? '';
      final shopId = fields['shop_id']?['stringValue'] ?? '';
      print('Bolge: ${b['name'].split('/').last} - $name, shop_id: $shopId');
    }
  }
}
