import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/region_provider.dart';
import '../../models/address_model.dart';
import '../../models/region_model.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/language_provider.dart';
import 'location_picker_page.dart';

class AddAddressPage extends StatefulWidget {
  final Address? existingAddress;

  const AddAddressPage({super.key, this.existingAddress});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _streetController;
  late TextEditingController _buildingNoController;
  late TextEditingController _floorController;
  late TextEditingController _doorNoController;
  late TextEditingController _detailsController;
  

  String? _selectedCity;
  String? _selectedDistrict;
  bool _isRegionsLoaded = false;
  String _selectedType = 'home';
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingAddress?.title ?? '');
    _cityController = TextEditingController(text: widget.existingAddress?.city ?? '');
    _districtController = TextEditingController(text: widget.existingAddress?.district ?? '');
    _streetController = TextEditingController(text: widget.existingAddress?.street ?? '');
    _buildingNoController = TextEditingController(text: widget.existingAddress?.buildingNo ?? '');
    _floorController = TextEditingController(text: widget.existingAddress?.floor ?? '');
    _doorNoController = TextEditingController(text: widget.existingAddress?.doorNo ?? '');
    _detailsController = TextEditingController(text: widget.existingAddress?.fullAddress ?? '');
    

    _selectedCity = widget.existingAddress?.city;
    _selectedDistrict = widget.existingAddress?.district;
    
    // Load regions when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegionProvider>().fetchRegions().then((_) {
        if (mounted) setState(() => _isRegionsLoaded = true);
      });
    });

    _selectedType = widget.existingAddress?.type ?? 'home';
    _latitude = widget.existingAddress?.latitude;
    _longitude = widget.existingAddress?.longitude;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _streetController.dispose();
    _buildingNoController.dispose();
    _floorController.dispose();
    _doorNoController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);

      final newAddress = Address(
        id: widget.existingAddress?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        city: _selectedCity ?? '',
        district: _selectedDistrict ?? '',
        street: _streetController.text.trim(),
        buildingNo: _buildingNoController.text.trim(),
        floor: _floorController.text.trim(),
        doorNo: _doorNoController.text.trim(),
        fullAddress: _detailsController.text.trim(),
        type: _selectedType,
        isDefault: widget.existingAddress?.isDefault ?? false,
        latitude: _latitude,
        longitude: _longitude,
      );

      setState(() => _isLoading = true);
      try {
        if (widget.existingAddress == null) {
          await addressProvider.addAddress(newAddress);
          if (addressProvider.addresses.length == 1) {
             await addressProvider.setDefaultAddress(newAddress.id);
          }
        } else {
          await addressProvider.updateAddress(widget.existingAddress!.id, newAddress);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Adres başarıyla kaydedildi!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          debugPrint("SUBMIT HATASI: $e");
          _showErrorDialog(e.toString());
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⚠️ Kayıt Başarısız"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("TAMAM"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.existingAddress == null ? "Yeni Adres Ekle" : "Adresi Düzenle",
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMapSelector(),
              const SizedBox(height: 24),
              
              _buildSectionTitle("ADRES BİLGİLERİ"),
              _buildInput(_titleController, "Adres Başlığı (Örn: Ev, İş, Annemler)", Icons.label_important_outline),
              
              Consumer<RegionProvider>(
                builder: (context, regionProvider, child) {
                  if (regionProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final regions = regionProvider.regions;
                  Region? currentRegion;
                  try {
                    currentRegion = regions.firstWhere((r) => r.name == _selectedCity);
                  } catch (e) {
                    currentRegion = null;
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCity,
                          decoration: InputDecoration(
                            labelText: langProvider.translate('city_label'),
                            prefixIcon: const Icon(Icons.location_city_rounded, color: AppColors.primary),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                          ),
                          items: regions.map((r) => DropdownMenuItem(value: r.name, child: Text(r.name))).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCity = val;
                              _selectedDistrict = null; // Reset district when city changes
                            });
                          },
                          validator: (val) => val == null || val.isEmpty ? langProvider.translate('select_city') : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDistrict,
                          decoration: InputDecoration(
                            labelText: langProvider.translate('district_label'),
                            prefixIcon: const Icon(Icons.map_outlined, color: AppColors.primary),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                          ),
                          items: currentRegion?.districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList() ?? [],
                          onChanged: (val) {
                            setState(() {
                              _selectedDistrict = val;
                            });
                          },
                          validator: (val) => val == null || val.isEmpty ? langProvider.translate('select_district') : null,
                        ),
                      ),
                    ],
                  );
                }
              ),
              
              _buildInput(_streetController, "Sokak / Cadde", Icons.add_road_rounded),
              
              Row(
                children: [
                  Expanded(child: _buildInput(_buildingNoController, "Bina No", Icons.business_rounded)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInput(_floorController, "Kat", Icons.layers_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInput(_doorNoController, "Daire", Icons.door_front_door_outlined)),
                ],
              ),

              _buildInput(_detailsController, "Adres Tarifi / Tam Adres", Icons.description_outlined, maxLines: 2),
              
              const SizedBox(height: 12),
              _buildSectionTitle("ADRES TİPİ"),
              Row(
                children: [
                  _buildTypeChip("Ev", Icons.home_rounded, "home"),
                  const SizedBox(width: 12),
                  _buildTypeChip("İş", Icons.work_rounded, "work"),
                  const SizedBox(width: 12),
                  _buildTypeChip("Diğer", Icons.place_rounded, "other"),
                ],
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("ADRESİ KAYDET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey[500], letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon, String value) {
    bool isSelected = _selectedType == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2)),
            boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 1)),
        ),
        validator: (v) => v!.trim().isEmpty ? "" : null,
      ),
    );
  }

  Widget _buildMapSelector() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LocationPickerPage()),
        );

        if (result != null && result is Map<String, dynamic>) {
          setState(() {
            _latitude = result['lat'];
            _longitude = result['lng'];
            if (result['city'] != null) _cityController.text = result['city'];
            if (result['district'] != null) _districtController.text = result['district'];
            if (result['street'] != null) _streetController.text = result['street'];
            if (result['address'] != null) _detailsController.text = result['address'];
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _latitude == null ? "Haritadan Konum Seç" : "Konum İşaretlendi",
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _latitude == null 
                      ? "Adresinizi harita üzerinde işaretleyerek kesin konumunuzu belirleyin." 
                      : "Koordinatlar başarıyla alındı ve form dolduruldu.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
