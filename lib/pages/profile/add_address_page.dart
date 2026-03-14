import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../../core/constants/app_colors.dart';

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
  String _selectedType = 'home'; // Varsayılan tip

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
    _selectedType = widget.existingAddress?.type ?? 'home';
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final addressProvider = Provider.of<AddressProvider>(
        context,
        listen: false,
      );

      final newAddress = Address(
        id: widget.existingAddress?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        city: _cityController.text,
        district: _districtController.text,
        fullAddress: _detailsController.text,
        type: _selectedType,
        isDefault: widget.existingAddress?.isDefault ?? false,
      );

      try {
        if (widget.existingAddress == null) {
          await addressProvider.addAddress(newAddress);
        } else {
          await addressProvider.updateAddress(widget.existingAddress!.id, newAddress);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingAddress == null ? "Adres Ekle" : "Adresi Güncelle",
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
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
              const Text(
                "Adres Tipi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTypeChip("Ev", Icons.home, "home"),
                  _buildTypeChip("İş", Icons.work, "work"),
                  _buildTypeChip("Diğer", Icons.location_on, "other"),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                  child: const Text(
                    "KAYDET",
                    style: TextStyle(
                      color: AppColors.textPrimary,
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

  Widget _buildTypeChip(String label, IconData icon, String value) {
    bool isSelected = _selectedType == value;
    return ChoiceChip(
      label: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AppColors.textPrimary : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedType = value;
          });
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textPrimary : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
          ),
        ),
        validator: (v) => v!.isEmpty ? "Boş bırakılamaz" : null,
      ),
    );
  }
}
