import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';

class AddAddressPage extends StatefulWidget {
  final Address? existingAddress; // Varsa düzenleme modundadır

  const AddAddressPage({super.key, this.existingAddress});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingAddress?.title ?? '',
    );
    _cityController = TextEditingController(
      text: widget.existingAddress?.city ?? '',
    );
    _districtController = TextEditingController(
      text: widget.existingAddress?.district ?? '',
    );
    _detailsController = TextEditingController(
      text: widget.existingAddress?.fullAddress ?? '',
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final addressProvider = Provider.of<AddressProvider>(
        context,
        listen: false,
      );

      final newAddress = Address(
        id: widget.existingAddress?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        city: _cityController.text,
        district: _districtController.text,
        fullAddress: _detailsController.text,
      );

      if (widget.existingAddress == null) {
        addressProvider.addAddress(newAddress);
      } else {
        addressProvider.updateAddress(widget.existingAddress!.id, newAddress);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingAddress == null ? "Adres Ekle" : "Adresi Güncelle",
        ),
        backgroundColor: const Color(0xFF5D3EBD),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInput(_titleController, "Adres Başlığı (Örn: Ev, İş)"),
              _buildInput(_cityController, "Şehir"),
              _buildInput(_districtController, "İlçe"),
              _buildInput(_detailsController, "Tam Adres Detayı", maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3EBD),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "KAYDET",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (v) => v!.isEmpty ? "Boş bırakılamaz" : null,
      ),
    );
  }
}
