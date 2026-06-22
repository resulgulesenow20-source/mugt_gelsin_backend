import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import 'add_address_page.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/language_provider.dart';

class MyAddressesPage extends StatefulWidget {
  const MyAddressesPage({super.key});

  @override
  State<MyAddressesPage> createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    if (!mounted) return;
    await Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final langProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.get('addresses'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAddressPage()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : addressProvider.addresses.isEmpty
              ? _buildEmptyState(langProvider)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addressProvider.addresses.length,
                  itemBuilder: (context, index) {
                    final address = addressProvider.addresses[index];
                    return _buildAddressCard(address, addressProvider, langProvider);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddAddressPage()),
        ),
        backgroundColor: AppColors.primary,
        label: Text(langProvider.get('add_address').toUpperCase(), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildEmptyState(LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded, size: 80, color: Colors.grey.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            lang.get('no_address'),
            style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAddressPage()),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(lang.get('add_first_address'), style: const TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address, AddressProvider provider, LanguageProvider lang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: address.isDefault ? AppColors.primary : Colors.black.withOpacity(0.08),
          width: address.isDefault ? 2 : 1,
        ),
      ),
      elevation: address.isDefault ? 4 : 0,
      child: InkWell(
        onTap: () => provider.setDefaultAddress(address.id),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: address.isDefault ? AppColors.primary : Colors.grey.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  address.type == 'home' ? Icons.home_rounded : address.type == 'work' ? Icons.work_rounded : Icons.place_rounded,
                  color: address.isDefault ? AppColors.textPrimary : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (address.isDefault)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lang.get('default'),
                              style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${address.district}, ${address.city}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Text(
                      "${address.street} No:${address.buildingNo}, Kat:${address.floor} Daire:${address.doorNo}",
                      style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.fullAddress,
                      style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(address, provider, lang),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Address address, AddressProvider provider, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.get('delete_address')),
        content: Text(lang.get('delete_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(lang.get('cancel').toUpperCase())),
          TextButton(
            onPressed: () {
              provider.deleteAddress(address.id);
              Navigator.pop(context);
            },
            child: Text(lang.get('clear').toUpperCase(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
