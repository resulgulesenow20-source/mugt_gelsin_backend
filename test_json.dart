import 'dart:convert';

void main() {
  try {
    final orderData = {
      'customerUid': 'test1',
      'firestore_id': 'test2',
      'shop_id': 'test3',
      'shop_name': 'test4',
      'customerName': 'test',
      'customerPhone': '123',
      'note': '',
      'totalPrice': 50.0,
      'status': 'onaylanıyor',
      'paymentMethod': 'kapida_nakit',
      'cardId': null,
      'items': [
        {
          'name': 'Food',
          'quantity': 1,
          'price': 100.0,
        }
      ],
      'itemsSummary': '1x Food',
      'deliveryAddress': 'Address',
    };
    
    final dataToSend = {
      ...orderData,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final jsonString = json.encode(dataToSend);
    print('Encoding successful: $jsonString');
  } catch (e) {
    print('Error encoding: $e');
  }
}
