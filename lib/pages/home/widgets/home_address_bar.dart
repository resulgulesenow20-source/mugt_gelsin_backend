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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.isLoggedIn
                        ? (defaultAddress?.title ?? langProvider.translate('address_select'))
                        : (regionProvider.selectedGuestRegion ?? langProvider.translate('address_select')),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (authProvider.isLoggedIn && defaultAddress != null)
                    Text(
                      defaultAddress.district,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (!authProvider.isLoggedIn && regionProvider.selectedGuestRegion != null)
                    Text(
                      langProvider.translate('select_region_title'), // Just a subtitle indicator
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

