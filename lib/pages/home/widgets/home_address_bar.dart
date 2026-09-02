import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/address_provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart';
import 'package:mugut_gelsin/providers/region_provider.dart';
import 'package:mugut_gelsin/pages/profile/my_addresses_page.dart';
import 'package:mugut_gelsin/pages/home/widgets/region_selection_dialog.dart';

class HomeAddressBar extends StatelessWidget {
  const HomeAddressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final authProvider = context.watch<AuthProvider>();
    final regionProvider = context.watch<RegionProvider>();
    final defaultAddress = addressProvider.defaultAddress;

    return InkWell(
      onTap: () {
        if (authProvider.isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyAddressesPage()),
          );
        } else {
          RegionSelectionDialog.show(context);
        }
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF2B0F6B), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Teslimat Adresi",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    authProvider.isLoggedIn
                        ? ((defaultAddress?.title ?? "") + " " + (defaultAddress?.district ?? langProvider.translate('address_select')))
                        : (regionProvider.selectedGuestRegion ?? langProvider.translate('address_select')),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black87, size: 24),
          ],
        ),
      ),
    );
  }
}

