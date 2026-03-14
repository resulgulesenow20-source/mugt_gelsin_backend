import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mugt_gelsin/models/restaurant_model.dart';
import 'package:mugt_gelsin/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugt_gelsin/pages/home/widgets/home_address_bar.dart';
import 'package:mugt_gelsin/pages/home/widgets/home_search_bar.dart';
import 'package:mugt_gelsin/pages/home/widgets/active_order_widget.dart';
import 'package:mugt_gelsin/pages/home/widgets/home_empty_state.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';
import 'package:mugt_gelsin/providers/language_provider.dart';
import 'package:mugt_gelsin/pages/home/widgets/banner_slider.dart';
import 'package:mugt_gelsin/pages/home/widgets/category_list.dart';
import 'package:mugt_gelsin/pages/home/widgets/filter_chips.dart';
import 'package:mugt_gelsin/pages/home/widgets/horizontal_restaurant_list.dart';
import 'package:mugt_gelsin/pages/home/widgets/restaurant_grid.dart';
import 'package:mugt_gelsin/services/api_service.dart';
import 'package:mugt_gelsin/utils/dummy_data.dart';
import 'package:mugt_gelsin/pages/home/widgets/horizontal_food_list.dart';
import 'package:mugt_gelsin/presentation/common/cards/food_card.dart';
import 'package:mugt_gelsin/pages/restaurant/restaurant_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Restaurant> displayedRestaurants = [];
  List<Restaurant> allRestaurants = []; // ✅ Orijinal listeyi tutmak için
  List<FoodWithRestaurant> cheapestFoods = []; // ✅ En ucuz yemekler listesi
  List<FoodWithRestaurant> matchedFoods = []; // ✅ Arama ile eşleşen yemekler
  String _searchQuery = ""; // ✅ Mevcut arama sorgusu
  bool isLoading = true;
  Timer? _searchDebounce; // ✅ Arama geciktirici (performans için)
  int _lastResetCounter = 0; // ✅ Sıfırlama takibi için
  final ScrollController _scrollController = ScrollController(); // ✅ Yukarı kaydırmak için

  void _showAllFoods() {
    setState(() {
      _searchQuery = "Tüm Ürünler";
      matchedFoods = [];
      for (var res in allRestaurants) {
        for (var food in res.menu) {
          matchedFoods.add(FoodWithRestaurant(
            food: food,
            restaurantId: res.id,
            restaurantName: res.name,
          ));
        }
      }
      displayedRestaurants = List.from(allRestaurants);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData(); // ✅ Veriyi servisten çek
  }

  @override
  void dispose() {
    _searchDebounce?.cancel(); // ✅ Timer'ı temizle
    _scrollController.dispose(); // ✅ Controller'ı temizle
    super.dispose();
  }

  Future<void> _loadData() async {
    final apiService = ApiService();
    final restaurants = await apiService.fetchRestaurants();
    setState(() {
      if (restaurants.isEmpty) {
        allRestaurants = dummyRestaurants; // ✅ Hata durumunda dummy veri göster
        // Hata durumunda kullanıcıyı bilgilendir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Sunucuya bağlanılamadı, demo veriler gösteriliyor."),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        allRestaurants = restaurants;
      }

      // ✅ EN UCUZ YEMEKLERİ HESAPLA
      cheapestFoods = [];
      for (var res in allRestaurants) {
        for (var food in res.menu) {
          cheapestFoods.add(FoodWithRestaurant(
            food: food,
            restaurantId: res.id,
            restaurantName: res.name,
          ));
        }
      }
      // Fiyata göre sırala ve ilk 10'u al
      cheapestFoods.sort((a, b) => a.food.price.compareTo(b.food.price));
      if (cheapestFoods.length > 10) {
        cheapestFoods = cheapestFoods.sublist(0, 10);
      }

      displayedRestaurants = List.from(allRestaurants);
      isLoading = false;
    });
  }

  void _filterRestaurants(String query) {
    // ✅ Performans için debounce ekle
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      setState(() {
        _searchQuery = query;
        if (query.isEmpty) {
          displayedRestaurants = List.from(allRestaurants);
          matchedFoods = [];
        } else {
          final lowercaseQuery = query.toLowerCase();
          
          // 1. Restoran Filtreleme
          displayedRestaurants = allRestaurants.where((res) {
            final nameMatch = res.name.toLowerCase().contains(lowercaseQuery);
            final foodMatch = res.menu.any((food) => 
              food.name.toLowerCase().contains(lowercaseQuery) || 
              food.description.toLowerCase().contains(lowercaseQuery)
            );
            return nameMatch || foodMatch;
          }).toList();

          // 2. Özel Ürün Eşleşmeleri
          matchedFoods = [];
          for (var res in allRestaurants) {
            for (var food in res.menu) {
              if (food.name.toLowerCase().contains(lowercaseQuery) || 
                  food.description.toLowerCase().contains(lowercaseQuery)) {
                matchedFoods.add(FoodWithRestaurant(
                  food: food,
                  restaurantId: res.id,
                  restaurantName: res.name,
                ));
              }
            }
          }
        }
      });
    });
  }

  void _filterByCategory(String categoryName) {
    setState(() {
      _searchQuery = ""; // Kategori seçilince aramayı temizle
      if (categoryName == "Hepsi") {
        displayedRestaurants = List<Restaurant>.from(allRestaurants);
      } else {
        displayedRestaurants = allRestaurants
            .where(
              (res) => res.category.toLowerCase() == categoryName.toLowerCase(),
            )
            .toList();
      }
    });
  }

  void _navigateToRestaurant(String restaurantId) {
    final restaurant = allRestaurants.firstWhere(
      (res) => res.id == restaurantId,
      orElse: () => allRestaurants.first,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailPage(restaurant: restaurant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ NAVIGASYON VE DİL TAKİBİ
    final navProvider = context.watch<NavigationProvider>();
    final langProvider = context.watch<LanguageProvider>();
    
    // ✅ SIFIRLAMA SİNYALİ KONTROLÜ
    if (navProvider.resetHomeCounter > _lastResetCounter) {
      _lastResetCounter = navProvider.resetHomeCounter;
      _searchQuery = "";
      matchedFoods = [];
      displayedRestaurants = List.from(allRestaurants);

      // Sayfayı en yukarı kaydır
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    if (navProvider.homeMode == HomeMode.allProducts && _searchQuery != "Tüm Ürünler" && !isLoading) {
      // Bir sonraki frame'de çalışması için WidgetsBinding kullan
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAllFoods();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          langProvider.translate('app_name'),
        ),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                controller: _scrollController, // ✅ Buraya bağla
                child: Column(
                  children: [
                    // ADRES VE ARAMA ÇUBUĞU YAN YANA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          // Adres Seçimi (Sol Taraf)
                          const Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 48,
                              child: HomeAddressBar(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Arama Çubuğu (Sağ Taraf)
                          Expanded(
                            flex: 6,
                            child: HomeSearchBar(
                                onSearchChanged: _filterRestaurants,
                                onRefresh: _loadData,
                            ),
                          ),
                        ],
                      ),
                    ),
                    (_searchQuery.isNotEmpty && displayedRestaurants.isEmpty && matchedFoods.isEmpty) ||
                    (_searchQuery.isEmpty && displayedRestaurants.isEmpty)
                        ? HomeEmptyState(onRetry: _loadData)
                        : Column(
                            children: [
                              // 🔍 ARAMA MODU: Sadece ürünler ve dükkanlar
                              if (_searchQuery.isNotEmpty) ...[
                                if (matchedFoods.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Eşleşen Ürünler",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                    ),
                                  ),
                                  // ✅ PERFORMANS: ListView.builder yerine Column içinde map() yerine builder kullanıldı
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: matchedFoods.length,
                                      itemBuilder: (context, index) {
                                        final item = matchedFoods[index];
                                        return FoodCard(
                                          food: item.food,
                                          restaurantId: item.restaurantId,
                                          restaurantName: item.restaurantName,
                                          onTap: () => _navigateToRestaurant(item.restaurantId),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Eşleşen Restoranlar",
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                RestaurantGrid(restaurants: displayedRestaurants),
                              ],

                              // 🏠 ANA SAYFA MODU: Banner, Kategori, Fırsatlar
                              if (_searchQuery.isEmpty) ...[
                                const BannerSlider(),
                                const FilterChips(),
                                CategoryList(
                                  onCategorySelected: (category) => _filterByCategory(category),
                                ),
                                const ActiveOrderWidget(),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        langProvider.translate('highlights'),
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  HorizontalRestaurantList(restaurants: displayedRestaurants),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        langProvider.translate('cheapest'),
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  HorizontalFoodList(
                                    items: cheapestFoods,
                                    onItemTap: (item) => _navigateToRestaurant(item.restaurantId),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        langProvider.translate('restaurants'),
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                RestaurantGrid(restaurants: displayedRestaurants),
                              ],
                            ],
                          ),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
    );
  }


}
