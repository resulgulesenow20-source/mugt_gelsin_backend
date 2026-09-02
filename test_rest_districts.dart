import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final resDuk = await http.get(Uri.parse('https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/Dukkanlar'));
  final dukkanlar = json.decode(resDuk.body);
  
  if (dukkanlar['documents'] != null) {
    for (var d in dukkanlar['documents']) {
      final fields = d['fields'] ?? {};
      final mugutId = fields['mugut_id']?['stringValue'] ?? '';
      
      if (mugutId == 'mugut_1839') {
        final deliveryDistricts = fields['deliveryDistricts']?['arrayValue']?['values'] ?? [];
        print('deliveryDistricts for mugut_1839: $deliveryDistricts');
      }
    }
  }
}
