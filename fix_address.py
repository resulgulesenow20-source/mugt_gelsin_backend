import os

def fix_address_page():
    with open('lib/pages/profile/add_address_page.dart', 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # 1. Add RegionProvider import
    if "import '../../providers/region_provider.dart';" not in content:
        content = content.replace("import '../../providers/address_provider.dart';", "import '../../providers/address_provider.dart';\nimport '../../providers/region_provider.dart';")
        content = content.replace("import '../../models/address_model.dart';", "import '../../models/address_model.dart';\nimport '../../models/region_model.dart';")

    # 2. Add Selected City/District state variables in initState
    if "String? _selectedCity;" not in content:
        state_vars = """
  String? _selectedCity;
  String? _selectedDistrict;
  bool _isRegionsLoaded = false;
"""
        content = content.replace("  String _selectedType = 'home';", state_vars + "  String _selectedType = 'home';")
        
        init_state_updates = """
    _selectedCity = widget.existingAddress?.city;
    _selectedDistrict = widget.existingAddress?.district;
    
    // Load regions when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegionProvider>().fetchRegions().then((_) {
        if (mounted) setState(() => _isRegionsLoaded = true);
      });
    });
"""
        content = content.replace("    _selectedType = widget.existingAddress?.type ?? 'home';", init_state_updates + "\n    _selectedType = widget.existingAddress?.type ?? 'home';")

    # 3. Replace the TextFields for City and District with Dropdowns
    old_row = """              Row(
                children: [
                  Expanded(child: _buildInput(_cityController, "zehir", Icons.location_city_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(_districtController, "lA e", Icons.map_outlined)),
                ],
              ),"""
    
    old_row_ascii = """              Row(
                children: [
                  Expanded(child: _buildInput(_cityController, "Şehir", Icons.location_city_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(_districtController, "İlçe", Icons.map_outlined)),
                ],
              ),"""

    new_dropdowns = """              Consumer<RegionProvider>(
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
                            labelText: "Şehir (Welaýat)",
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
                          validator: (val) => val == null || val.isEmpty ? "Şehir seçin" : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDistrict,
                          decoration: InputDecoration(
                            labelText: "İlçe (Etrap)",
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
                          validator: (val) => val == null || val.isEmpty ? "İlçe seçin" : null,
                        ),
                      ),
                    ],
                  );
                }
              ),"""

    # We might have encoding issues matching the text. Let's just find the exact lines
    lines = content.split('\n')
    start_idx = -1
    end_idx = -1
    for i, line in enumerate(lines):
        if "Icons.location_city_rounded" in line and "_buildInput(" in line:
            start_idx = i - 2
            end_idx = i + 4
            break
            
    if start_idx != -1:
        lines = lines[:start_idx] + [new_dropdowns] + lines[end_idx:]
        content = '\n'.join(lines)

    # 4. Modify the `_submitForm` to use _selectedCity and _selectedDistrict
    content = content.replace("city: _cityController.text.trim(),", "city: _selectedCity ?? '',")
    content = content.replace("district: _districtController.text.trim(),", "district: _selectedDistrict ?? '',")
    
    with open('lib/pages/profile/add_address_page.dart', 'w', encoding='utf-8') as f:
        f.write(content)

fix_address_page()
