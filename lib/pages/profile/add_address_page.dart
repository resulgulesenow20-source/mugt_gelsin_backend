import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/region_provider.dart';
import '../../models/address_model.dart';
import '../../models/region_model.dart';
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
    _streetController = TextEditingController(text: widget.existingAddress?.street ?? '');
    _buildingNoController = TextEditingController(text: widget.existingAddress?.buildingNo ?? '');
    _floorController = TextEditingController(text: widget.existingAddress?.floor ?? '');
    _doorNoController = TextEditingController(text: widget.existingAddress?.doorNo ?? '');
    _detailsController = TextEditingController(text: widget.existingAddress?.fullAddress ?? '');

    _selectedCity = widget.existingAddress?.city;
    _selectedDistrict = widget.existingAddress?.district;
    
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
        title: _selectedType == 'home' ? 'Öý' : _selectedType == 'work' ? 'Iş' : 'Başga',
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
              content: Text("Salgy üstünlikli ýatda saklandy!"),
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
        title: const Text("⚠️ Ýalňyşlyk"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BOLÝAR"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDFA),
      appBar: AppBar(
        title: Text(
          widget.existingAddress == null ? "Täze Salgy Goş" : "Salgyny Üýtget",
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2B0F6B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: Stack(
        children: [
          // Dark purple background extension for the top
          Container(
            height: 100,
            color: const Color(0xFF2B0F6B),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  _buildMapSelector(),
                  const SizedBox(height: 8),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle("SALGY MAGLUMATLARY"),
                        
                        Consumer<RegionProvider>(
                          builder: (context, regionProvider, child) {
                            if (regionProvider.isLoading) {
                              return const Center(child: CircularProgressIndicator(color: Color(0xFF2B0F6B)));
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
                                  flex: 5,
                                  child: _buildDropdown(
                                    value: _selectedCity,
                                    label: "Welaýat",
                                    icon: Icons.grid_view_rounded,
                                    items: regions.map((r) => r.name).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedCity = val;
                                        _selectedDistrict = null;
                                      });
                                    },
                                    validator: (val) => val == null || val.isEmpty ? "Welaýat saýlaň" : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 4,
                                  child: _buildDropdown(
                                    value: _selectedDistrict,
                                    label: "Etrap",
                                    icon: Icons.view_column_rounded,
                                    items: currentRegion?.districts ?? [],
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedDistrict = val;
                                      });
                                    },
                                    validator: (val) => val == null || val.isEmpty ? "Etrap saýlaň" : null,
                                  ),
                                ),
                              ],
                            );
                          }
                        ),
                        
                        _buildInput(_streetController, "Köçe / Şaýoly", Icons.add_road_rounded),
                        
                        Row(
                          children: [
                            Expanded(flex: 3, child: _buildInput(_buildingNoController, "Bina...", Icons.business_rounded)),
                            const SizedBox(width: 10),
                            Expanded(flex: 3, child: _buildInput(_floorController, "Gat", Icons.layers_outlined)),
                            const SizedBox(width: 10),
                            Expanded(flex: 3, child: _buildInput(_doorNoController, "Gap...", Icons.door_front_door_outlined)),
                          ],
                        ),

                        _buildInput(_detailsController, "Salgy Doly Maglumaty", Icons.description_outlined),
                        
                        const SizedBox(height: 4),
                        _buildSectionTitle("SALGY GÖRNÜŞI"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTypeChip("Öý", Icons.home_rounded, "home"),
                            _buildTypeChip("Iş", Icons.work_rounded, "work"),
                            _buildTypeChip("Başga", Icons.place_rounded, "other"),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD500),
                              foregroundColor: const Color(0xFF2B0F6B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: _isLoading 
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF2B0F6B)))
                              : const Text("Salgyny ýatda sakla", style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w900)),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            "Hemme zat taýýar bolanda eltip bereris.",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, top: 12),
      child: Text(
        title,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2B0F6B), letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon, String value) {
    bool isSelected = _selectedType == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFD500) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF2B0F6B) : const Color(0xFF2B0F6B), size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: const Color(0xFF2B0F6B),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {double height = 56}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF2B0F6B)),
        maxLines: height > 60 ? 3 : 1,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(fontFamily: 'Inter', color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF2B0F6B), size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 16, right: 16, top: height > 60 ? 16 : 18, bottom: height > 60 ? 16 : 18),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          icon: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFFFD500)),
          ),
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF2B0F6B)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF2B0F6B), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(top: 14),
          ),
          hint: Text(label, style: TextStyle(fontFamily: 'Inter', color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildMapSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LocationPickerPage()),
          );

          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _latitude = result['lat'];
              _longitude = result['lng'];
              if (result['city'] != null) _selectedCity = result['city'];
              if (result['district'] != null) _selectedDistrict = result['district'];
              if (result['street'] != null) _streetController.text = result['street'];
              if (result['address'] != null) _detailsController.text = result['address'];
            });
          }
        },
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: AssetImage('assets/images/delivery_map_banner.png'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Stack(
            children: [

              // Bottom right hint text
              const Positioned(
                bottom: 24,
                right: 24,
                child: Text(
                  "Ýer saýla",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Color(0xFF2B0F6B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

