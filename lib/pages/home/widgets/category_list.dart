import 'package:flutter/material.dart';
import 'package:mugut_gelsin/utils/dummy_data.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/models/top_category_model.dart';

class CategoryList extends StatelessWidget {
  final Function(String) onCategorySelected;
  final List<TopCategory>? topCategories;

  const CategoryList({super.key, required this.onCategorySelected, this.topCategories});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxGridWidth = screenWidth > 600 ? 600 : screenWidth;
    final double itemWidth = (maxGridWidth - 32 - 16) / 4; // 4 columns! 4x2 grid

    List<Widget> gridItems = [];
    
    if (topCategories != null && topCategories!.isNotEmpty) {
      for (var cat in topCategories!) {
        gridItems.add(_buildDynamicCard(context, cat, itemWidth, onCategorySelected));
      }
    } else {
      // Fallback if empty
      for (int i = 1; i <= 8; i++) {
        gridItems.add(_buildDefaultCard(context, i, itemWidth, lang, onCategorySelected));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: SizedBox(
          width: maxGridWidth,
          child: Wrap(
            spacing: 5,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: gridItems,
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicCard(BuildContext context, TopCategory cat, double width, Function(String) onCategorySelected) {
    return _buildColumnCard(
      width: width,
      title: cat.title,
      onTap: () {
        onCategorySelected(cat.targetCategory);
      },
      imageWidget: Image.network(
        cat.imageUrl,
        height: width,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.fastfood_rounded, size: 32, color: AppColors.primary)),
      ),
    );
  }

  Widget _buildDefaultCard(BuildContext context, int index, double width, LanguageProvider lang, Function(String) onCategorySelected) {
    switch (index) {
      case 7:
        return _buildColumnCard(
          width: width,
          title: 'Burger',
          onTap: () => onCategorySelected("Burger"),
          imageWidget: Image.asset(
            'assets/images/cat_burger.png',
            height: width,
            width: width,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.fastfood_rounded, size: 32, color: AppColors.primary)),
          ),
        );
      case 8:
      default:
        return _buildColumnCard(
          width: width,
          title: 'Hepsi',
          onTap: () => onCategorySelected("Hepsi"),
          imageWidget: const Center(
            child: Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 36),
          ),
        );
    }
  }

  Widget _buildColumnCard({
    required double width,
    required String title,
    required VoidCallback onTap,
    required Widget imageWidget,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: width * 0.9, // Slightly smaller than full width to leave room for shadow
              height: width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
