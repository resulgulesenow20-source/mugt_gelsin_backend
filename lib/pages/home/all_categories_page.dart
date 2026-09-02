import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/models/top_category_model.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';

class AllCategoriesPage extends StatelessWidget {
  final List<TopCategory> categories;

  const AllCategoriesPage({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate width to match 4 items per row with padding
    final double padding = 16.0;
    final double crossAxisSpacing = 8.0;
    final double itemWidth = (screenWidth - (padding * 2) - (crossAxisSpacing * 3)) / 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          langProvider.translate('categories') == 'categories' ? "Kategoriler" : (langProvider.translate('categories') ?? "Kategoriler"),
          style: const TextStyle(
            color: AppColors.textTitle,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textTitle),
      ),
      body: categories.isEmpty
          ? const Center(child: Text("Kategoriya ýok"))
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65, // Adjust for image + text
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, cat.targetCategory);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: itemWidth,
                        height: itemWidth,
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: Image.network(
                              cat.imageUrl,
                              height: itemWidth * 0.85,
                              width: itemWidth * 0.85,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.fastfood_rounded, size: 32, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
