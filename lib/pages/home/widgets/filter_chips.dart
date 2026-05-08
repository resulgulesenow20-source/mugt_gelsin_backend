import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';

class FilterChips extends StatefulWidget {
  const FilterChips({super.key});

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  final Set<String> _selectedFilters = {};

  void _toggleFilter(String label) {
    setState(() {
      if (_selectedFilters.contains(label)) {
        _selectedFilters.remove(label);
      } else {
        _selectedFilters.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      {"label": "Filtrele", "icon": Icons.tune_rounded, "isMain": true},
      {"label": "Teslimat Süresi", "icon": Icons.access_time_rounded, "isMain": false},
      {"label": "Restoran Puanı", "icon": Icons.star_rounded, "isMain": false},
      {"label": "Mutfak", "icon": Icons.restaurant_menu_rounded, "isMain": false},
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final String label = filter['label'] as String;
          final bool isMain = filter['isMain'] as bool;
          
          final bool isSelected = _selectedFilters.contains(label);
          final bool isActive = isMain || isSelected;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                if (!isMain) {
                  _toggleFilter(label);
                } else {
                  // Filtrele butonuna tıklandığında yapılacaklar buraya eklenebilir
                }
              },
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: isActive ? null : Border.all(color: Colors.grey.shade200),
                  boxShadow: isActive ? AppColors.premiumShadow : AppColors.softShadow,
                ),
                child: Row(
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 18,
                      color: isActive ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isActive ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

