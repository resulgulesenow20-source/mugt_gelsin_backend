import 'package:flutter/material.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mugt_gelsin/providers/cart_provider.dart';
import 'package:mugt_gelsin/providers/address_provider.dart';
import 'package:mugt_gelsin/providers/payment_provider.dart';
import 'package:mugt_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugt_gelsin/models/address_model.dart';
import 'package:mugt_gelsin/pages/order/order_confirm_page.dart';
import 'package:mugt_gelsin/pages/orders/order_tracking_page.dart';
import 'package:mugt_gelsin/services/api_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = false;
  String _paymentMethod = 'kapida_nakit'; // 'kapida_nakit', 'kapida_kart', 'online_kart'
  String? _selectedCardId;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında adresleri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddresses();
      context.read<PaymentProvider>().fetchCards();
      
      // Varsayılan telefon numarasını AuthProvider'dan alıp dolduralım
      final auth = context.read<app_auth.AuthProvider>();
      if (auth.userData?['phone'] != null) {
        _phoneController.text = auth.userData?['phone'];
      }
    });
  }

  Future<void> _sendOrderToFirebase(
    BuildContext context,
    CartProvider cart,
    Address? address,
    PaymentProvider paymentProvider,
  ) async {
    if (_isLoading) return;

    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir teslimat adresi seçin.")),
      );
      return;
    }

    // Seçili online ödeme ise kart kontrolü yap
    if (_paymentMethod == 'online_kart') {
      if (paymentProvider.cards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen önce bir ödeme yöntemi ekleyin.")),
        );
        return;
      }
      _selectedCardId ??= paymentProvider.cards.firstWhere((c) => c.isDefault, orElse: () => paymentProvider.cards.first).id;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<app_auth.AuthProvider>();
      final customerName = authProvider.userData?['name'] ?? "Bilinmeyen Müşteri";
      final customerPhone = _phoneController.text.trim();
      final orderNote = _noteController.text.trim();
      final customerUid = authProvider.user?.uid;
      
      if (customerPhone.isEmpty) {
        throw "Lütfen bir iletişim numarası girin.";
      }

      // Opsiyonel: Eğer profil telefonu boşsa veya kullanıcı farklı bir numara girmişse 
      // profil bilgilerini güncellemeyi teklif edebiliriz veya doğrudan güncelleyebiliriz.
      // Şimdilik sadece bu sipariş için kullanıyoruz.
      // Gelecekte ana profili de güncelleyebiliriz:
      final storedPhone = authProvider.userData?['phone']?.toString() ?? "";
      if (storedPhone != customerPhone) {
        await authProvider.updateUserData({'phone': customerPhone});
      }

      // 1. Önce Firestore'dan bir doküman referansı oluşturup ID alıyoruz
      final orderRef = FirebaseFirestore.instance.collection('Emirler').doc();
      final firestoreId = orderRef.id;

      final orderData = {
        'customerUid': customerUid,
        'firestore_id': firestoreId,
        'shop_id': cart.restaurantId ?? 'unknown_shop',
        'shop_name': cart.restaurantName ?? 'İsimsiz Dükkan',
        'customerName': customerName,
        'customerPhone': customerPhone,
        'note': orderNote,
        'totalPrice': cart.totalPrice,
        'status': 'onaylanıyor', // İlk durum: Onay bekliyor/İşleniyor
        'paymentMethod': _paymentMethod,
        'cardId': _paymentMethod == 'online_kart' ? _selectedCardId : null,
        'items': cart.items.map((item) => {
          'name': item.food.name,
          'quantity': item.quantity,
          'price': item.food.price,
        }).toList(),
        'itemsSummary': cart.items
            .map((item) => "${item.quantity}x ${item.food.name}")
            .join(", "),
        'deliveryAddress': address.fullAddress,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // 2. HEMEN Firestore'a Kaydet (Böylece sipariş geçmişinde hemen görünür)
      await orderRef.set(orderData);

      // 3. Flask Backend'e Gönder (Admin Paneli İçin)
      final apiService = ApiService();
      final backendSuccess = await apiService.placeOrder({
        ...orderData,
        'timestamp': DateTime.now().toIso8601String(), // JSON için string formatı
      });

      if (backendSuccess) {
        // Dükkan siparişi aldı, durumu güncelle
        await orderRef.update({'status': 'hazırlanıyor'});
        
        cart.clearCart();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderTrackingPage(orderId: firestoreId),
            ),
          );
        }
      } else {
        // Dükkan siparişi alamadı (Sunucu kapalı olabilir)
        await orderRef.update({'status': 'iletilemedi'});
        throw "Sipariş dükkana iletilemedi, ancak geçmişinize kaydedildi. Lütfen dükkanla iletişime geçin.";
      }

    } catch (e) {
      debugPrint("Sipariş gönderme hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();

    final selectedAddress = addressProvider.addresses.isNotEmpty
        ? addressProvider.addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addressProvider.addresses.first,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Siparişi Tamamla"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Teslimat Adresi",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildAddressCard(selectedAddress),
                      const SizedBox(height: 25),
                      const Text(
                        "Ödeme Yöntemi",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildPaymentMethods(context),
                      const SizedBox(height: 25),
                      const Text(
                        "İletişim Bilgileri",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(_phoneController, "Telefon Numarası", Icons.phone, TextInputType.phone),
                      const SizedBox(height: 20),
                      const Text(
                        "Sipariş Notu",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(_noteController, "Notunuzu buraya yazabilirsiniz...", Icons.note_add, TextInputType.text),
                      const SizedBox(height: 25),
                      const Text(
                        "Sipariş Özeti",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
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
          const Icon(Icons.location_on, color: AppColors.primary),
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
                          color: AppColors.textSecondary,
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

  Widget _buildPaymentMethods(BuildContext context) {
    return Column(
      children: [
        _buildPaymentOption('kapida_nakit', 'Kapıda Nakit', Icons.money),
        _buildPaymentOption('kapida_kart', 'Kapıda Kredi Kartı', Icons.credit_card),
        _buildPaymentOption('online_kart', 'Uygulama İçi Kredi Kartı', Icons.app_registration),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    bool isSelected = _paymentMethod == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _paymentMethod,
        onChanged: (val) => setState(() => _paymentMethod = val!),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        secondary: Icon(icon, color: isSelected ? AppColors.textPrimary : Colors.grey),
        activeColor: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPaymentBar(
    BuildContext context,
    CartProvider cart,
    Address? address,
  ) {
    final double minOrderAmount = cart.minOrderAmount;
    final bool isBelowMinOrder = cart.totalPrice < minOrderAmount;
    final paymentProvider = context.read<PaymentProvider>();
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: (_isLoading || isBelowMinOrder)
                  ? null
                  : () => _sendOrderToFirebase(context, cart, address, paymentProvider),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: isBelowMinOrder
                      ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400])
                      : AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isBelowMinOrder
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isBelowMinOrder ? "MİNİMUM TUTAR ALTINDA" : "SİPARİŞİ ONAYLA",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
