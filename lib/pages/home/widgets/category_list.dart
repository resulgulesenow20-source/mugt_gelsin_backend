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
    
    // We want about 5.6 items visible so it's horizontally scrollable and slightly smaller
    final double itemWidth = screenWidth > 600 ? 75 : (screenWidth - 32) / 5.6;

    List<Widget> listItems = [];
    
    if (topCategories != null && topCategories!.isNotEmpty) {
      for (int i = 0; i < topCategories!.length; i++) {
        listItems.add(_buildDynamicCard(context, topCategories![i], i, itemWidth, onCategorySelected));
        if (i < topCategories!.length - 1) {
          listItems.add(const SizedBox(width: 6));
        }
      }
    } else {
      // Fallback if empty
      for (int i = 1; i <= 8; i++) {
        listItems.add(_buildDefaultCard(context, i, itemWidth, lang, onCategorySelected));
        if (i < 8) {
          listItems.add(const SizedBox(width: 6));
        }
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: listItems,
      ),
    );
  }

  Widget _buildDynamicCard(BuildContext context, TopCategory cat, int index, double width, Function(String) onCategorySelected) {
    return _buildColumnCard(
      width: width,
      index: index,
      title: cat.title,
      onTap: () {
        onCategorySelected(cat.targetCategory);
      },
      imageWidget: Image.network(
        cat.imageUrl,
        height: width * 0.85, // Made larger to reduce empty space
        width: width * 0.85,
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
          index: index,
          title: 'Burger',
          onTap: () => onCategorySelected("Burger"),
          imageWidget: Image.asset(
            'assets/images/cat_burger.png',
            height: width * 0.85,
            width: width * 0.85,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.fastfood_rounded, size: 32, color: AppColors.primary)),
          ),
        );
      case 8:
      default:
        return _buildColumnCard(
          width: width,
          index: index,
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
    required int index,
    required String title,
    required VoidCallback onTap,
    required Widget imageWidget,
  }) {
    final color = const Color(0xFF5D3EBC); // Purple border
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
              width: width, 
              height: width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: color.withOpacity(0.6), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: imageWidget,
                ),
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
