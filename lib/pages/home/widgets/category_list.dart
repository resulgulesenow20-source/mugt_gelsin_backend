import 'package:flutter/material.dart';
import 'package:mugut_gelsin/utils/dummy_data.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';

class CategoryList extends StatelessWidget {
  final Function(String) onCategorySelected;

  const CategoryList({super.key, required this.onCategorySelected});

  String _getTranslatedName(String name, LanguageProvider lang) {
    if (name.contains("Burger")) return lang.get("burger");
    if (name.contains("Pizza")) return lang.get("pizza");
    if (name.contains("Kebap")) return lang.get("kebab");
    if (name.contains("Tatli")) return lang.get("dessert");
    if (name.contains("Deniz")) return lang.get("seafood");
    return lang.get(name);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxGridWidth = screenWidth > 600 ? 600 : screenWidth;
    final double itemWidth = (maxGridWidth - 32 - 16) / 3; // 16 padding on sides, 8 gap between items = 16 total gap

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: SizedBox(
          width: maxGridWidth,
          child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // 1. İN ARZANLAR
          _buildCustomCard(
            width: itemWidth,
            backgroundColor: AppColors.primary,
            child: Center(
              child: Text(
                lang.selectedLang == 'TR' ? "EN UCUZLAR" : (lang.selectedLang == 'TM' ? "IŇ ARZANLAR" : "САМЫЕ ДЕШЕВЫЕ"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  height: 1.1,
                ),
              ),
            ),
            onTap: () {
              // Navigate to cheapest
            },
          ),
          
          // 2. İNDİRİMLİ
          _buildCustomCard(
            width: itemWidth,
            backgroundColor: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/indirimli_restoranlar.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    "%50\nİNDİRİM",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            onTap: () {
              // Navigate to discounts
            },
          ),

          // 3. Kebap
          _buildCategoryCard(dummyCategories.firstWhere((c) => c.name.contains("Kebap"), orElse: () => dummyCategories.first), itemWidth, lang),

          // 4. Tatlı
          _buildCategoryCard(dummyCategories.firstWhere((c) => c.name.contains("Tatli"), orElse: () => dummyCategories.first), itemWidth, lang),

          // 5. Deniz Ürünü
          _buildCategoryCard(dummyCategories.firstWhere((c) => c.name.contains("Deniz"), orElse: () => dummyCategories.first), itemWidth, lang),

          // 6. Ählisi (Tümü)
          _buildCustomCard(
            width: itemWidth,
            backgroundColor: AppColors.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.grid_view_rounded, color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  lang.get('all'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            onTap: () => onCategorySelected("Hepsi"),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildCustomCard({required double width, required Color backgroundColor, required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: width, // Square
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildCategoryCard(category, double width, LanguageProvider lang) {
    return GestureDetector(
      onTap: () => onCategorySelected(category.name),
      child: Container(
        width: width,
        height: width, // Square
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              category.imageUrl,
              height: 40,
              width: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.fastfood_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getTranslatedName(category.name, lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

