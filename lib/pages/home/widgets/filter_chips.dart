import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';

class FilterChips extends StatelessWidget {
  final Set<String> selectedFilters;
  final ValueChanged<String> onFilterToggled;

  const FilterChips({
    super.key,
    required this.selectedFilters,
    required this.onFilterToggled,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    final filters = [
      {"label": lang.get('delivery_time'), "icon": Icons.access_time_rounded},
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: filters.map((filter) {
          final String label = filter['label'] as String;
          final bool isSelected = selectedFilters.contains(label);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => onFilterToggled(label),
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                  boxShadow: isSelected ? AppColors.premiumShadow : AppColors.softShadow,
                ),
                child: Row(
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 18,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
