import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/providers/address_provider.dart';
import 'package:mugut_gelsin/providers/payment_provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugut_gelsin/models/address_model.dart';
import 'package:mugut_gelsin/pages/orders/order_tracking_page.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:mugut_gelsin/services/api_service.dart';
import 'package:mugut_gelsin/pages/profile/my_addresses_page.dart';
import 'package:mugut_gelsin/models/campaign_model.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = false;
  String _paymentMethod = 'kapida_nakit'; // 'kapida_nakit', 'kapida_kart', 'online_kart'
  String? _selectedCardId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();
  
  Campaign? _appliedCampaign;
  double _discountAmount = 0.0;
  bool _isCheckingCoupon = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında adresleri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddresses();
      context.read<PaymentProvider>().fetchCards();
      
      // Varsayılan verileri AuthProvider'dan alıp dolduralım
      final auth = context.read<app_auth.AuthProvider>();
      if (auth.userData?['name'] != null && auth.userData?['name'] != 'Kullanıcı') {
        _nameController.text = auth.userData?['name'];
      }
      if (auth.userData?['phone'] != null) {
        _phoneController.text = auth.userData?['phone'];
      }
    });
  }

  Future<void> _applyCoupon(CartProvider cart, LanguageProvider lang) async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _isCheckingCoupon = true);

    try {
      final apiService = ApiService();
      final campaigns = await apiService.fetchCampaigns();
      
      final campaign = campaigns.firstWhere(
        (c) => c.code?.toUpperCase() == code && (c.shopId == cart.restaurantId),
        orElse: () => throw lang.get('invalid_coupon'),
      );

      if (cart.totalPrice < campaign.minAmount) {
        throw "${lang.get('below_min_amount')}: ${campaign.minAmount.toStringAsFixed(0)} TMT";
      }

      double discount = 0.0;
      if (campaign.type == 'percentage') {
        discount = cart.totalPrice * (campaign.value / 100);
      } else {
        discount = campaign.value;
      }

      setState(() {
        _appliedCampaign = campaign;
        _discountAmount = discount;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${lang.get('coupon_applied')} ${discount.toStringAsFixed(2)} TMT"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
      setState(() {
        _appliedCampaign = null;
        _discountAmount = 0.0;
      });
    } finally {
      setState(() => _isCheckingCoupon = false);
    }
  }

  Future<void> _sendOrderToFirebase(
    BuildContext context,
    CartProvider cart,
    Address? address,
    PaymentProvider paymentProvider,
    LanguageProvider lang,
  ) async {
    if (_isLoading) return;

    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.get('select_address_error'))),
      );
      return;
    }

    if (_paymentMethod == 'online_kart') {
      if (paymentProvider.cards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.get('add_payment_error'))),
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
      final customerName = _nameController.text.trim();
      final customerPhone = _phoneController.text.trim();
      final orderNote = _noteController.text.trim();
      final customerUid = authProvider.user?.uid;
      
      if (customerName.isEmpty || customerName == 'Kullanıcı') {
        throw lang.get('enter_name_error');
      }

      if (customerPhone.isEmpty) {
        throw lang.get('enter_phone_error');
      }

      final storedName = authProvider.userData?['name']?.toString() ?? "";
      if (storedName != customerName) {
        await authProvider.updateUserData({'name': customerName});
      }

      final storedPhone = authProvider.userData?['phone']?.toString() ?? "";
      if (storedPhone != customerPhone) {
        await authProvider.updateUserData({'phone': customerPhone});
      }

      final orderRef = FirebaseFirestore.instance.collection('Emirler').doc();
      final firestoreId = orderRef.id;

      final orderData = {
        'customerUid': customerUid,
        'id': firestoreId,
        'firestore_id': firestoreId,
        'shop_id': cart.restaurantId ?? 'unknown_shop',
        'shop_name': cart.restaurantName ?? lang.get('unnamed_shop'),
        'customer': customerName,
        'customerName': customerName,
        'contact': customerPhone,
        'customerPhone': customerPhone,
        'summary': cart.items
            .map((item) => "${item.quantity}x ${item.food.name}${item.note != null ? " (${item.note})" : ""}")
            .join(", "),
        'note': orderNote,
        'total': (cart.totalPrice - _discountAmount).toStringAsFixed(2),
        'totalPrice': cart.totalPrice - _discountAmount,
        'originalPrice': cart.totalPrice,
        'discountAmount': _discountAmount,
        'couponCode': _appliedCampaign?.code,
        'status': 'onay bekliyor',
        'payment': _paymentMethod == 'online_kart' ? lang.get('online_payment') : (_paymentMethod == 'kapida_nakit' ? lang.get('cash_on_delivery') : lang.get('card_on_delivery')),
        'paymentMethod': _paymentMethod,
        'platform': 'MUGUT GELSİN', 
        'items': cart.items.map((item) => {
          'name': item.food.name,
          'quantity': item.quantity,
          'price': item.food.price,
          'note': item.note,
          'imageUrl': item.food.imageUrl,
        }).toList(),
        'deliveryAddress': address.fullAddress,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'time': DateTime.now().toLocal().toString().substring(11, 16),
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await orderRef.set(orderData);

      cart.clearCart();
      if (mounted) {
        final navProvider = context.read<NavigationProvider>();
        Navigator.pop(context);
        navProvider.switchToOrdersWithTracking(firestoreId);
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
    final langProvider = context.watch<LanguageProvider>();

    final selectedAddress = addressProvider.addresses.isNotEmpty
        ? addressProvider.addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addressProvider.addresses.first,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.get('complete_order')),
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
                      Text(
                        langProvider.get('delivery_address'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildAddressCard(selectedAddress, langProvider),
                      const SizedBox(height: 25),
                      Text(
                        langProvider.get('payment_methods'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildPaymentMethods(context, langProvider),
                      const SizedBox(height: 25),
                      Text(
                        langProvider.get('full_name'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(_nameController, langProvider.get('full_name'), Icons.person, TextInputType.name),
                      const SizedBox(height: 20),
                      Text(
                        langProvider.get('phone_label'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(_phoneController, langProvider.get('phone_label'), Icons.phone, TextInputType.phone, maxLength: 8),
                      const SizedBox(height: 20),
                      Text(
                        langProvider.get('order_note'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(_noteController, "...", Icons.note_add, TextInputType.text),
                      const SizedBox(height: 10),
                      _buildCouponInput(cartProvider, langProvider),
                      const SizedBox(height: 25),
                      Text(
                        langProvider.get('order_summary'),
                        style: const TextStyle(
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
                            subtitle: item.note != null 
                              ? Text(item.note!, style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic))
                              : null,
                            trailing: Text(
                              "${(item.food.price * item.quantity).toStringAsFixed(2)} TMT",
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              _buildPaymentBar(context, cartProvider, selectedAddress, langProvider),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, TextInputType type, {int? maxLength}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: label,
        counterText: "",
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
        ),
      ),
    );
  }

  Widget _buildAddressCard(dynamic selectedAddress, LanguageProvider lang) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyAddressesPage()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
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
                  : Text(lang.get('please_add_address')),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context, LanguageProvider lang) {
    return Column(
      children: [
        _buildPaymentOption('kapida_nakit', lang.get('cash_on_delivery'), Icons.money),
        _buildPaymentOption('kapida_kart', lang.get('card_on_delivery'), Icons.credit_card),
        _buildPaymentOption('online_kart', lang.get('online_payment'), Icons.app_registration),
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
          color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.1),
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
    LanguageProvider lang,
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
                Text(lang.get('total_price'), style: const TextStyle(fontSize: 16)),
                Text(
                  "${(cart.totalPrice - _discountAmount).toStringAsFixed(2)} TMT",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (_discountAmount > 0) ...[
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(lang.get('discount'), style: const TextStyle(color: Colors.green, fontSize: 14)),
                  Text("-${_discountAmount.toStringAsFixed(2)} TMT", style: const TextStyle(color: Colors.green, fontSize: 14)),
                ],
              ),
            ],
            const SizedBox(height: 15),
            GestureDetector(
              onTap: (_isLoading || isBelowMinOrder)
                  ? null
                  : () => _sendOrderToFirebase(context, cart, address, paymentProvider, lang),
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
                          isBelowMinOrder ? lang.get('below_min_amount') : lang.get('complete_order').toUpperCase(),
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

  Widget _buildCouponInput(CartProvider cart, LanguageProvider lang) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _couponController,
              decoration: InputDecoration(
                hintText: lang.get('coupon_hint'),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ),
          if (_isCheckingCoupon)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: () => _applyCoupon(cart, lang),
              child: Text(
                _appliedCampaign != null ? lang.get('update') : lang.get('apply'),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

