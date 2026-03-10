import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mugt_gelsin/providers/cart_provider.dart';
import 'package:mugt_gelsin/providers/address_provider.dart';
// ✅ Firebase Paketini Ekledik
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  // ✅ Firebase'e veri gönderen fonksiyonu buraya ekledik

  Future<void> _sendOrderToFirebase(
    BuildContext context,
    CartProvider cart,
    dynamic address,
  ) async {
    try {
      final orderData = {
        'customerName': "Resul (Mobil)",
        'totalPrice': cart.totalPrice,
        'status': 'hazırlanıyor',
        'itemsSummary': cart.items
            .map((item) => "${item.quantity}x ${item.food.name}")
            .join(", "),
        'deliveryAddress': address != null
            ? address.fullAddress
            : "Adres belirtilmedi",
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('Emirler').add(orderData);

      // ❌ SnackBar yok
      // ❌ Dialog yok
      // ✅ sadece geri dön
      return;
    } catch (e) {
      debugPrint("Sipariş gönderme hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();

    final selectedAddress = addressProvider.addresses.isNotEmpty
        ? addressProvider.addresses.first
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Siparişi Tamamla"),
        backgroundColor: const Color(0xFF5D3EBD),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Teslimat Adresi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildAddressCard(selectedAddress),
                  const SizedBox(height: 25),
                  const Text(
                    "Sipariş Özeti",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("${item.quantity}x ${item.food.name}"),
                        trailing: Text(
                          "${(item.food.price * item.quantity).toStringAsFixed(2)} TL",
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildPaymentBar(context, cartProvider, selectedAddress),
        ],
      ),
    );
  }

  Widget _buildAddressCard(selectedAddress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF5D3EBD)),
          const SizedBox(width: 12),
          Expanded(
            child: selectedAddress != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAddress.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        selectedAddress.fullAddress,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : const Text("Lütfen bir adres ekleyin"),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBar(
    BuildContext context,
    CartProvider cart,
    dynamic address,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Toplam Tutar", style: TextStyle(fontSize: 16)),
                Text(
                  "${cart.totalPrice.toStringAsFixed(2)} TL",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D3EBD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3EBD),
                ),
                // ✅ Siparişi onayla butonuna Firebase fonksiyonunu bağladık
                onPressed: () => _sendOrderToFirebase(context, cart, address),
                child: const Text(
                  "SİPARİŞİ ONAYLA",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 15),
            const Text(
              "Sipariş Alındı!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                cart.clearCart();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Ana Sayfaya Dön"),
            ),
          ],
        ),
      ),
    );
  }
}
