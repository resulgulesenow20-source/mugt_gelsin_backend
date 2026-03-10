import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import 'add_address_page.dart';

class MyAddressesPage extends StatelessWidget {
  const MyAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Adreslerim")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5D3EBD),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddAddressPage()),
        ),
      ),
      body: ListView.builder(
        itemCount: addressProvider.addresses.length,
        itemBuilder: (context, index) {
          final addr = addressProvider.addresses[index];
          return ListTile(
            leading: const Icon(Icons.location_on, color: Color(0xFF5D3EBD)),
            title: Text(addr.title),
            subtitle: Text("${addr.district}, ${addr.city}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddAddressPage(existingAddress: addr),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => addressProvider.deleteAddress(addr.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
