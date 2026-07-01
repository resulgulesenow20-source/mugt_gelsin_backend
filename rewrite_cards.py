import re

with open('lib/pages/home/widgets/category_list.dart', 'r', encoding='utf-8') as f:
    content = f.read()

parts = content.split("  Widget _buildSponsoredCard(BuildContext context, Restaurant restaurant, double itemWidth) {")

if len(parts) != 2:
    print("Could not find _buildSponsoredCard")
    exit(1)

top_part = parts[0]

new_methods = """  Widget _buildSponsoredCard(BuildContext context, Restaurant restaurant, double itemWidth) {
    return _buildColumnCard(
      width: itemWidth,
      backgroundColor: Colors.grey[200]!,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          restaurant.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primary),
        ),
      ),
      text: restaurant.name,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(restaurant: restaurant),
          ),
        );
      },
    );
  }

  Widget _buildDefaultCard(BuildContext context, int slot, double itemWidth, LanguageProvider lang, Function(String) onCategorySelected) {
    switch (slot) {
      case 1:
        return _buildColumnCard(
          width: itemWidth,
          backgroundColor: AppColors.primary,
          child: const Center(
            child: Icon(Icons.star_rounded, color: Colors.white, size: 32),
          ),
          text: lang.selectedLang == 'TR' ? "Meşhur" : (lang.selectedLang == 'TM' ? "Meşhur" : "Известные"),
          onTap: () => onCategorySelected('Meşhur'),
        );
      case 2:
        return _buildColumnCard(
          width: itemWidth,
          backgroundColor: Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/indirimli_restoranlar.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.local_offer, color: AppColors.primary, size: 32),
              ),
            ),
          ),
          text: "%50 İndirim",
          onTap: () {}, // Navigate to discounts
        );
      case 3:
        return _buildCategoryCard(dummyCategories.firstWhere((c) => c.name.contains("Kebap"), orElse: () => dummyCategories.first), itemWidth, lang, onCategorySelected);
      case 4:
        return _buildCategoryCard(dummyCategories.firstWhere((c) => c.name.contains("Tatli"), orElse: () => dummyCategories.first), itemWidth, lang, onCategorySelected);
      case 5:
        return _buildCategoryCard(dummyCategories.firstWhere((c) => c.name.contains("Deniz"), orElse: () => dummyCategories.first), itemWidth, lang, onCategorySelected);
      case 6:
        return _buildCategoryCard(dummyCategories.firstWhere((c) => c.name.contains("Kahve") || c.name.contains("İçecek"), orElse: () => dummyCategories.first), itemWidth, lang, onCategorySelected);
      case 7:
        return _buildCategoryCard(dummyCategories.firstWhere((c) => c.name.contains("Döner") || c.name.contains("Çiğ"), orElse: () => dummyCategories.first), itemWidth, lang, onCategorySelected);
      case 8:
      default:
        return _buildColumnCard(
          width: itemWidth,
          backgroundColor: AppColors.primary,
          child: const Center(
            child: Icon(Icons.grid_view_rounded, color: Colors.white, size: 32),
          ),
          text: lang.get('all'),
          onTap: () => onCategorySelected('Tümü'),
        );
    }
  }

  Widget _buildColumnCard({required double width, required Color backgroundColor, required Widget child, required String text, required VoidCallback onTap}) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
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
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              height: 1.1,
              letterSpacing: -0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(category, double width, LanguageProvider lang, Function(String) onCategorySelected) {
    return _buildColumnCard(
      width: width,
      backgroundColor: Colors.white,
      child: Center(
        child: Image.asset(
          category.imageUrl,
          height: width * 0.6,
          width: width * 0.6,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.fastfood_rounded,
            size: 32,
            color: AppColors.primary,
          ),
        ),
      ),
      text: _getTranslatedName(category.name, lang),
      onTap: () => onCategorySelected(category.name),
    );
  }
}
"""

with open('lib/pages/home/widgets/category_list.dart', 'w', encoding='utf-8') as f:
    f.write(top_part + new_methods)
print("done")
