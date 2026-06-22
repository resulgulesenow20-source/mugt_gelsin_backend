import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../models/payment_model.dart';
import '../../core/constants/app_colors.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final rawNumber = _numberController.text.replaceAll(' ', '');
      final maskedNumber = "**** **** **** ${rawNumber.substring(rawNumber.length - 4)}";
      
      String type = 'visa';
      if (rawNumber.startsWith('5')) type = 'mastercard';

      final newCard = PaymentCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardHolder: _holderController.text,
        cardNumber: maskedNumber,
        expiryDate: _expiryController.text,
        cardType: type,
      );

      try {
        await Provider.of<PaymentProvider>(context, listen: false).addCard(newCard);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: $e")),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Kart Ekle"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildCardPreview(),
              const SizedBox(height: 30),
              _buildTextField(_holderController, "Kart Üzerindeki İsim", "AD SOYAD"),
              const SizedBox(height: 16),
              _buildTextField(_numberController, "Kart Numarası", "0000 0000 0000 0000", isNumber: true, maxLength: 19),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_expiryController, "Son Kullanma", "AA/YY", isNumber: true, maxLength: 5)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_cvvController, "CVV", "000", isNumber: true, maxLength: 3, isCvv: true)),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("KARTI KAYDET", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Align(alignment: Alignment.topRight, child: Icon(Icons.credit_card, color: Colors.white24, size: 40)),
            const Text(
              "**** **** **** ****",
              style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 2),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("KART SAHİBİ", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text(_holderController.text.isEmpty ? "AD SOYAD" : _holderController.text.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("VALID THRU", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text(_expiryController.text.isEmpty ? "00/00" : _expiryController.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isNumber = false, int? maxLength, bool isCvv = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      obscureText: isCvv,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        floatingLabelStyle: const TextStyle(color: AppColors.textPrimary),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.textPrimary, width: 2)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Boş bırakılamaz";
        if (isNumber && value.length < (maxLength ?? 0)) return "Eksik bilgi";
        return null;
      },
    );
  }
}
