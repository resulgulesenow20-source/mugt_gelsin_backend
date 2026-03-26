import 'package:flutter/material.dart';
import 'package:mugut_gelsin/presentation/common/inputs/custom_search_field.dart';
import 'package:mugut_gelsin/pages/profile/live_support_page.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';

class HomeSearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onRefresh;

  const HomeSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Row(
      children: [
        Expanded(
          child: CustomSearchField(
            onChanged: onSearchChanged,
            hintText: langProvider.translate('search_hint'),
          ),
        ),
        const SizedBox(width: 8),
        // âœ… DESTEK SAYFASINA GÄ°DEN BUTON
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LiveSupportPage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: AppColors.softShadow,
            ),
            child: const Center(
              child: Icon(
                Icons.support_agent_rounded, 
                color: AppColors.primary, 
                size: 24
              ),
            ),
          ),
        ),
      ],
    );
  }
}


