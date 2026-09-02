import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('settings').doc('translations').snapshots(),
      builder: (context, snapshot) {
        String hint = langProvider.translate('search_hint');
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data['TR'] != null && data['TR']['search_hint'] != null && data['TR']['search_hint'].toString().trim().isNotEmpty) {
            hint = data['TR']['search_hint'].toString();
          }
        }
        return CustomSearchField(
          onChanged: onSearchChanged,
          hintText: hint,
        );
      },
    );
  }
}


