import os

def fix_home_page():
    with open('lib/pages/home/home_page.dart', 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # We need to replace the old header (which has the "Kayan turuncu üst çubuk")
    # with the NEW white header that matches the screenshot exactly.
    
    # 1. Add _campaigns if missing
    if "List<Campaign> _campaigns" not in content:
        content = content.replace("import 'package:mugut_gelsin/providers/address_provider.dart';", "import 'package:mugut_gelsin/providers/address_provider.dart';\nimport 'package:mugut_gelsin/models/campaign_model.dart';")
        content = content.replace("List<Restaurant> allRestaurants = []; //", "List<Restaurant> allRestaurants = []; //\n  List<Campaign> _campaigns = []; //")

    # 2. Modify _loadData if campaignsData isn't there
    if "campaignsData =" not in content:
        content = content.replace("final restaurants = await apiService.fetchRestaurants();\n    setState(() {\n      if (restaurants.isEmpty) {", "final restaurants = await apiService.fetchRestaurants();\n    final campaignsData = await apiService.fetchCampaigns();\n    setState(() {\n      _campaigns = campaignsData.isEmpty ? dummyCampaigns : campaignsData;\n      if (restaurants.isEmpty) {")

    # 3. Replace the old Header with the screenshot-accurate Header
    old_header_start = content.find('                        // Kayan turuncu üst çubuk')
    old_header_end = content.find('                    (_searchQuery.isNotEmpty && displayedRestaurants.isEmpty && matchedFoods.isEmpty) ||')
    
    if old_header_start != -1 and old_header_end != -1:
        new_header = '''
                        // --- YENİ BEYAZ BAŞLIK (EKRAN GÖRÜNTÜSÜ BİREBİR) ---
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
                            ],
                          ),
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 8,
                            bottom: 16,
                            left: 16,
                            right: 16,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Sol: Mugut gelsin
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Mugut",
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18, height: 1.0, letterSpacing: -0.5),
                                      ),
                                      Text(
                                        "gelsin",
                                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18, height: 1.0, letterSpacing: -0.5),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  // Orta: Adres Çubuğu
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const HomeAddressBar(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Sağ: İkonlar
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 22),
                                        Positioned(
                                          top: 8,
                                          right: 10,
                                          child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                                    ),
                                    child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 22),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Arama Çubuğu
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: HomeSearchBar(
                                  onSearchChanged: _filterRestaurants,
                                  onRefresh: _loadData,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // --- BAŞLIK BİTİŞ ---
                        
                        // Alt Kısım (Gri Arka Plan)
                        Container(
                          color: AppColors.background,
                          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                          child: Column(
                            children: [
'''
        content = content[:old_header_start] + new_header + content[old_header_end:]

    # Fix the duplicate BannerSlider/CategoryList inside the old layout if they don't have campaigns
    if "BannerSlider(" in content and "campaigns: _campaigns," not in content:
        content = content.replace("BannerSlider(\n                                  restaurants: allRestaurants,", "BannerSlider(\n                                  campaigns: _campaigns,\n                                  restaurants: allRestaurants,")
        
    with open('lib/pages/home/home_page.dart', 'w', encoding='utf-8') as f:
        f.write(content)

def fix_category_list():
    with open('lib/pages/home/widgets/category_list.dart', 'w', encoding='utf-8') as f:
        f.write('''import 'package:flutter/material.dart';
import 'package:mugut_gelsin/utils/dummy_data.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';

class CategoryList extends StatelessWidget {
  final Function(String) onCategorySelected;

  const CategoryList({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxGridWidth = screenWidth > 600 ? 600 : screenWidth;
    final double itemWidth = (maxGridWidth - 32 - 16) / 4; // 4 columns! 4x2 grid

    final Map<int, Map<String, dynamic>> sponsoredMap = {
      1: {'name': 'Burger kIng', 'image': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400', 'id': 'burger_king_id'},
      2: {'name': 'Popeyes', 'image': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=400', 'id': 'popeyes_id'},
      3: {'name': 'Çağlayan pasta kafe', 'image': 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400', 'id': 'caglayan_id'},
      4: {'name': 'sosyete pilavcl', 'image': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400', 'id': 'sosyete_id'},
      5: {'name': 'dominos pIzza', 'image': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400', 'id': 'dominos_id'},
      6: {'name': 'Trent döner', 'image': 'https://images.unsplash.com/photo-1529042410759-befb1204b468?w=400', 'id': 'trent_id'},
    };

    List<Widget> gridItems = [];
    for (int i = 1; i <= 8; i++) {
      if (sponsoredMap.containsKey(i)) {
        gridItems.add(_buildSponsoredCard(context, sponsoredMap[i]!, itemWidth));
      } else {
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
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: gridItems,
          ),
        ),
      ),
    );
  }

  Widget _buildSponsoredCard(BuildContext context, Map<String, dynamic> data, double width) {
    return _buildColumnCard(
      width: width,
      backgroundColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              data['image'],
              height: width * 0.45,
              width: width * 0.45,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              data['name'],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 9,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildDefaultCard(BuildContext context, int index, double itemWidth, LanguageProvider lang, Function(String) onCategorySelected) {
    switch (index) {
      case 7:
        return _buildColumnCard(
          width: itemWidth,
          backgroundColor: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/cat_burger.png',
                  height: itemWidth * 0.45,
                  width: itemWidth * 0.45,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood_rounded, size: 32, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 6),
              const Text('Burger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Colors.black87, height: 1.1)),
            ],
          ),
          onTap: () => onCategorySelected("Burger"),
        );
      case 8:
      default:
        return _buildColumnCard(
          width: itemWidth,
          backgroundColor: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 32),
              const SizedBox(height: 8),
              const Text('Hepsi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
          onTap: () => onCategorySelected("Hepsi"),
        );
    }
  }

  Widget _buildColumnCard({required double width, required Color backgroundColor, required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: width * 1.1, 
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
''')

fix_home_page()
fix_category_list()
