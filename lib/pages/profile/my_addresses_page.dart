import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import 'add_address_page.dart';
import '../../core/constants/app_colors.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Adreslerim"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAddressPage()),
            ),
            tooltip: "Yeni Adres Ekle",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 150),
              itemCount: addressProvider.addresses.length,
              itemBuilder: (context, index) {
                final addr = addressProvider.addresses[index];
                return _buildAddressCard(context, addr, addressProvider);
              },
            ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Address addr, AddressProvider provider) {
    IconData iconData;
    switch (addr.type) {
      case 'work': iconData = Icons.work_outline; break;
      case 'other': iconData = Icons.location_on_outlined; break;
      default: iconData = Icons.home_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: addr.isDefault ? AppColors.primary : Colors.grey.shade200,
          width: addr.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: AppColors.textPrimary),
            ),
            title: Row(
              children: [
                Text(
                  addr.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (addr.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "VARSAYILAN",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "${addr.district}, ${addr.city}\n${addr.fullAddress}",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: addr.isDefault ? null : () => provider.setDefaultAddress(addr.id),
                  icon: Icon(
                    addr.isDefault ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: addr.isDefault ? Colors.green : Colors.grey,
                  ),
                  label: Text(
                    addr.isDefault ? "Varsayılan Adres" : "Varsayılan Yap",
                    style: TextStyle(
                      color: addr.isDefault ? Colors.green : Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddAddressPage(existingAddress: addr),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _showDeleteDialog(context, addr, provider),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Address addr, AddressProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Adresi Sil"),
        content: Text("${addr.title} adresini silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İPTAL"),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAddress(addr.id);
              Navigator.pop(context);
            },
            child: const Text("SİL", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
