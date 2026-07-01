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

    return CustomSearchField(
      onChanged: onSearchChanged,
      hintText: langProvider.translate('search_hint'),
    );
  }
}


