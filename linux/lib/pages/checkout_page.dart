import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mugt_gelsin/providers/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedAddress = "Evim (Merkez Mah. No:5)";
  String selectedPayment = "Kredi Kartı";

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("Siparişi Tamamla"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Teslimat Adresi"),
            _buildAddressCard(),
            const SizedBox(height: 24),
            _buildSectionTitle("Ödeme Yöntemi"),
            _buildPaymentMethod(),
            const SizedBox(height: 24),
            _buildSectionTitle("Sipariş Özeti"),
            _buildPriceSummary(cartProvider),
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(context, cartProvider),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF5D3EBD), size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(selectedAddress, style: const TextStyle(fontSize: 15)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Değiştir",
              style: TextStyle(color: Color(0xFF5D3EBD)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          RadioListTile(
            title: const Text("Kredi / Banka Kartı"),
            value: "Kredi Kartı",
            groupValue: selectedPayment,
            activeColor: const Color(0xFF5D3EBD),
            onChanged: (val) =>
                setState(() => selectedPayment = val.toString()),
          ),
          RadioListTile(
            title: const Text("Kapıda Ödeme (Nakit)"),
            value: "Nakit",
            groupValue: selectedPayment,
            activeColor: const Color(0xFF5D3EBD),
            onChanged: (val) =>
                setState(() => selectedPayment = val.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(CartProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _summaryRow(
            "Ara Toplam",
            "${provider.totalPrice.toStringAsFixed(2)} TL",
          ),
          _summaryRow("Teslimat Ücreti", "15.00 TL"),
          const Divider(height: 24),
          _summaryRow(
            "Genel Toplam",
            "${(provider.totalPrice + 15).toStringAsFixed(2)} TL",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF5D3EBD) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, CartProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5D3EBD),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _showSuccessDialog(context, provider),
        child: const Text(
          "Ödemeyi Yap ve Bitir",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, CartProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Siparişiniz Alındı!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "En kısa sürede kapınızda olacak.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                provider.clearCart(); // Sepeti boşalt
                Navigator.of(
                  context,
                ).popUntil((route) => route.isFirst); // Ana sayfaya dön
              },
              child: const Text("Ana Sayfaya Dön"),
            ),
          ],
        ),
      ),
    );
  }
}
