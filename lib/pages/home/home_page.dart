import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/pages/home/widgets/home_address_bar.dart';
import 'package:mugut_gelsin/pages/home/widgets/home_search_bar.dart';
import 'package:mugut_gelsin/pages/home/widgets/active_order_widget.dart';
import 'package:mugut_gelsin/pages/home/widgets/home_empty_state.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/pages/home/widgets/banner_slider.dart';
import 'package:mugut_gelsin/pages/home/widgets/category_list.dart';
import 'package:mugut_gelsin/pages/home/widgets/filter_chips.dart';
import 'package:mugut_gelsin/pages/home/widgets/horizontal_restaurant_list.dart';
import 'package:mugut_gelsin/pages/home/widgets/restaurant_grid.dart';
import 'package:mugut_gelsin/services/api_service.dart';
import 'package:mugut_gelsin/utils/dummy_data.dart';
import 'package:mugut_gelsin/pages/home/widgets/horizontal_food_list.dart';
import 'package:mugut_gelsin/presentation/common/cards/food_card.dart';
import 'package:mugut_gelsin/pages/restaurant/restaurant_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Restaurant> displayedRestaurants = [];
  List<Restaurant> allRestaurants = []; // âœ… Orijinal listeyi tutmak iÃ§in
  List<FoodWithRestaurant> cheapestFoods = []; // âœ… En ucuz yemekler listesi
  List<FoodWithRestaurant> matchedFoods = []; // âœ… Arama ile eÅŸleÅŸen yemekler
  String _searchQuery = ""; // âœ… Mevcut arama sorgusu
  bool isLoading = true;
  Timer? _searchDebounce; // âœ… Arama geciktirici (performans iÃ§in)
  int _lastResetCounter = 0; // âœ… SÄ±fÄ±rlama takibi iÃ§in
  final ScrollController _scrollController = ScrollController(); // âœ… YukarÄ± kaydÄ±rmak iÃ§in

  void _showAllFoods() {
    setState(() {
      _searchQuery = "TÃ¼m ÃœrÃ¼nler";
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
    _loadData(); // âœ… Veriyi servisten Ã§ek
  }

  @override
  void dispose() {
    _searchDebounce?.cancel(); // âœ… Timer'Ä± temizle
    _scrollController.dispose(); // âœ… Controller'Ä± temizle
    super.dispose();
  }

  Future<void> _loadData() async {
    final apiService = ApiService();
    final restaurants = await apiService.fetchRestaurants();
    setState(() {
      if (restaurants.isEmpty) {
        allRestaurants = dummyRestaurants; // âœ… Hata durumunda dummy veri gÃ¶ster
        // Hata durumunda kullanÄ±cÄ±yÄ± bilgilendir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Sunucuya baÄŸlanÄ±lamadÄ±, demo veriler gÃ¶steriliyor."),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        allRestaurants = restaurants;
      }

      // âœ… EN UCUZ YEMEKLERÄ° HESAPLA
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
      // Fiyata gÃ¶re sÄ±rala ve ilk 10'u al
      cheapestFoods.sort((a, b) => a.food.price.compareTo(b.food.price));
      if (cheapestFoods.length > 10) {
        cheapestFoods = cheapestFoods.sublist(0, 10);
      }

      displayedRestaurants = List.from(allRestaurants);
      isLoading = false;
    });
  }

  void _filterRestaurants(String query) {
    // âœ… Performans iÃ§in debounce ekle
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

          // 2. Ã–zel ÃœrÃ¼n EÅŸleÅŸmeleri
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
      _searchQuery = ""; // Kategori seÃ§ilince aramayÄ± temizle
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
    // âœ… NAVIGASYON VE DÄ°L TAKÄ°BÄ°
    final navProvider = context.watch<NavigationProvider>();
    final langProvider = context.watch<LanguageProvider>();
    
    // âœ… SIFIRLAMA SÄ°NYALÄ° KONTROLÃœ
    if (navProvider.resetHomeCounter > _lastResetCounter) {
      _lastResetCounter = navProvider.resetHomeCounter;
      _searchQuery = "";
      matchedFoods = [];
      displayedRestaurants = List.from(allRestaurants);

      // SayfayÄ± en yukarÄ± kaydÄ±r
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    if (navProvider.homeMode == HomeMode.allProducts && _searchQuery != "TÃ¼m ÃœrÃ¼nler" && !isLoading) {
      // Bir sonraki frame'de Ã§alÄ±ÅŸmasÄ± iÃ§in WidgetsBinding kullan
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAllFoods();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          langProvider.translate('app_name'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -1,
          ),
        ),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                controller: _scrollController, // âœ… Buraya baÄŸla
                child: Column(
                  children: [
                    // ADRES VE ARAMA Ã‡UBUÄžU YAN YANA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          // Adres SeÃ§imi (Sol Taraf)
                          const Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 48,
                              child: HomeAddressBar(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Arama Ã‡ubuÄŸu (SaÄŸ Taraf)
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
                              // ðŸ” ARAMA MODU: Sadece Ã¼rÃ¼nler ve dÃ¼kkanlar
                              if (_searchQuery.isNotEmpty) ...[
                                if (matchedFoods.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "EÅŸleÅŸen ÃœrÃ¼nler",
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // âœ… PERFORMANS: ListView.builder yerine Column iÃ§inde map() yerine builder kullanÄ±ldÄ±
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
                                      "EÅŸleÅŸen Restoranlar",
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                RestaurantGrid(restaurants: displayedRestaurants),
                              ],

                              // ðŸ  ANA SAYFA MODU: Banner, Kategori, FÄ±rsatlar
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
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        letterSpacing: -0.5,
                                      ),
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
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        letterSpacing: -0.5,
                                      ),
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
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 24,
                                        letterSpacing: -0.5,
                                      ),
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

