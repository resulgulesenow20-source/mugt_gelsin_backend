import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/pages/home/widgets/home_address_bar.dart';
import 'package:mugut_gelsin/pages/home/widgets/home_search_bar.dart';
import 'package:mugut_gelsin/pages/profile/live_support_page.dart';
import 'package:mugut_gelsin/pages/home/widgets/active_order_widget.dart';
import 'package:mugut_gelsin/pages/home/widgets/home_empty_state.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/pages/home/widgets/banner_slider.dart';
import 'package:mugut_gelsin/pages/home/widgets/category_list.dart';
import 'package:mugut_gelsin/pages/home/widgets/daily_offer_widget.dart';
import 'package:mugut_gelsin/pages/home/daily_offers_page.dart';
import 'package:mugut_gelsin/pages/home/widgets/wallet_progress_widget.dart';
import 'package:mugut_gelsin/pages/home/notifications_page.dart';
import 'package:mugut_gelsin/pages/home/widgets/filter_chips.dart';
import 'package:mugut_gelsin/pages/home/widgets/horizontal_restaurant_list.dart';
import 'package:mugut_gelsin/pages/home/widgets/restaurant_grid.dart';
import 'package:mugut_gelsin/services/api_service.dart';
import 'package:mugut_gelsin/utils/dummy_data.dart';
import 'package:mugut_gelsin/pages/home/widgets/horizontal_food_list.dart';
import 'package:mugut_gelsin/pages/restaurant/all_restaurants_page.dart';
import 'package:mugut_gelsin/pages/restaurant/all_foods_page.dart';
import 'package:mugut_gelsin/presentation/common/cards/food_card.dart';
import 'package:mugut_gelsin/pages/restaurant/restaurant_detail_page.dart';
import 'package:mugut_gelsin/providers/address_provider.dart';
import 'package:mugut_gelsin/models/campaign_model.dart';
import 'package:mugut_gelsin/models/top_category_model.dart';
import 'package:mugut_gelsin/pages/home/category_restaurants_page.dart';
import 'package:mugut_gelsin/providers/region_provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart';
import 'package:mugut_gelsin/pages/home/widgets/region_selection_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Restaurant> displayedRestaurants = [];
  List<Restaurant> allRestaurants = []; //
  List<Campaign> _campaigns = []; // âœ… Orijinal listeyi tutmak için
  List<TopCategory> _topCategories = []; // Dynamic Top Categories
  List<FoodWithRestaurant> cheapestFoods = []; // âœ… En ucuz yemekler listesi
  List<FoodWithRestaurant> matchedFoods = []; // âœ… Arama ile eşleşen yemekler
  String _searchQuery = ""; // âœ… Mevcut arama sorgusu
  bool isLoading = true;
  Timer? _searchDebounce; // âœ… Arama geciktirici (performans için)
  int _lastResetCounter = 0; // âœ… Sıfırlama takibi için
  final ScrollController _scrollController = ScrollController(); // âœ… Yukarı kaydırmak için
  Set<String> _selectedFilters = {}; // Missing filter state

  void _toggleFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
  }
  
  String _normalizeString(String text) {
    String normalized = text.toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ç', 'c');
        
    if (normalized.contains('askabat')) {
      normalized = normalized.replaceAll('askabat', 'asgabat');
    }
    return normalized;
  }

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
    _loadData(); // âœ… Veriyi servisten çek
    
    // Adresleri de yükle ki ana sayfada hemen görüksün
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      final addressProvider = context.read<AddressProvider>();
      final regionProvider = context.read<RegionProvider>();
      
      if (authProvider.isLoggedIn) {
        await addressProvider.fetchAddresses();
      }
      
      if (mounted && (!authProvider.isLoggedIn || addressProvider.addresses.isEmpty)) {
        if (regionProvider.selectedGuestRegion == null) {
          RegionSelectionDialog.show(context);
        }
      }
    });
  }

  List<Restaurant> _getRegionFilteredRestaurants(List<Restaurant> sourceList) {
    final addressProvider = context.read<AddressProvider>();
    final regionProvider = context.read<RegionProvider>();
    final authProvider = context.read<AuthProvider>();
    
    String? currentRegion;
    if (authProvider.isLoggedIn && addressProvider.defaultAddress != null) {
      currentRegion = addressProvider.defaultAddress!.city;
    } else {
      currentRegion = regionProvider.selectedGuestRegion;
    }
    
    if (currentRegion == null || currentRegion.isEmpty) return sourceList;
    
    final normCurrent = _normalizeString(currentRegion);
    
    return sourceList.where((r) {
      final normCity = _normalizeString(r.city);
      if (normCity.contains(normCurrent) || normCurrent.contains(normCity)) return true;
      
      for (var district in r.deliveryDistricts) {
        final normDistrict = _normalizeString(district);
        if (normDistrict.contains(normCurrent) || normCurrent.contains(normDistrict)) return true;
      }
      return false;
    }).toList();
  }

  List<Restaurant> get _currentDisplayedRestaurants {
    return _getRegionFilteredRestaurants(displayedRestaurants);
  }

  List<FoodWithRestaurant> get _currentMatchedFoods {
    final validResIds = _currentDisplayedRestaurants.map((e) => e.id).toSet();
    return matchedFoods.where((f) => validResIds.contains(f.restaurantId)).toList();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel(); // âœ… Timer'ı temizle
    _scrollController.dispose(); // âœ… Controller'ı temizle
    super.dispose();
  }

  Future<void> _loadData() async {
    final apiService = ApiService();
    final restaurants = await apiService.fetchRestaurants();
    List<Campaign> campaignsData = [];
    try {
      campaignsData = await apiService.fetchCampaigns();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Afiş Yükleme Hatası: $e"), duration: const Duration(seconds: 10)),
        );
      }
    }
    final topCategoriesData = await apiService.fetchTopCategories();
    setState(() {
      _campaigns = campaignsData;
      _topCategories = topCategoriesData;
      if (restaurants.isEmpty) {
        allRestaurants = dummyRestaurants; // âœ… Hata durumunda dummy veri göster
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

      // âœ… EN UCUZ YEMEKLERİ HESAPLA
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
    // âœ… Performans için debounce ekle
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
            final nameMatch = _normalizeString(res.name).contains(lowercaseQuery);
            final catMatch = _normalizeString(res.category).contains(lowercaseQuery);
            final foodMatch = res.menu.any((food) => 
              _normalizeString(food.name).contains(lowercaseQuery) || 
              _normalizeString(food.description).contains(lowercaseQuery)
            );
            return nameMatch || catMatch || foodMatch;
          }).toList();

          // 2. Özel Ürün Eşleşmeleri
          matchedFoods = [];
          for (var res in allRestaurants) {
            for (var food in res.menu) {
              if (_normalizeString(food.name).contains(lowercaseQuery) || 
                  _normalizeString(food.description).contains(lowercaseQuery)) {
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
    if (categoryName.toLowerCase() == "hepsi") {
      // "Hepsi" seçilirse arama sorgusunu temizle ve tüm restoranları göster
      setState(() {
        _searchQuery = "";
        displayedRestaurants = List<Restaurant>.from(allRestaurants);
      });
    } else {
      // Diğer kategorilerde yeni sayfaya git
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryRestaurantsPage(
            categoryName: categoryName,
            allRestaurants: allRestaurants,
          ),
        ),
      );
    }
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
    // âœ… NAVIGASYON VE DİL TAKİBİ
    final navProvider = context.watch<NavigationProvider>();
    final langProvider = context.watch<LanguageProvider>();
    
    // Region, Auth ve Address provider'larını izleyerek bölge değiştiğinde sayfanın yenilenmesini sağla
    context.watch<RegionProvider>();
    context.watch<AuthProvider>();
    context.watch<AddressProvider>();
    
    // âœ… SIFIRLAMA SİNYALİ KONTROLÜ
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
      backgroundColor: AppColors.background, // Beyaz/gri arka plan
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : Stack(
              children: [
                // Pull-to-refresh sırasında tepede "bölünme" (boşluk) görünmemesi için arkaya beyaz zemin atıyoruz.
                Positioned(
                  top: -500, // Extend way up for pull to refresh
                  left: 0,
                  right: 0,
                  height: 550, // 500 up + 50 down
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2B0F6B), // Same as header for seamless stretch
                    ),
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(), // Important for stretch feel
                    child: Column(
                      children: [

                        // --- YENİ BEYAZ BAŞLIK (EKRAN GÖRÜNTÜSÜ BİREBİR) ---
                        Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 8,
                            bottom: 24, // Padding at bottom of the purple header
                            left: 16,
                            right: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B0F6B), // Dark Purple
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.elliptical(MediaQuery.of(context).size.width, 20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Sol: Menü İkonu
                              IconButton(
                                icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer(); // If you have a drawer, else do nothing for now
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              // Orta: Logo
                              // Orta: Logo Çizimi
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(-8.0, 0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 6.0, top: 10.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(width: 12, height: 4, decoration: BoxDecoration(color: const Color(0xFFFFC824), borderRadius: BorderRadius.circular(2))),
                                                const SizedBox(height: 4),
                                                Container(width: 8, height: 4, decoration: BoxDecoration(color: const Color(0xFFFFC824), borderRadius: BorderRadius.circular(2))),
                                                const SizedBox(height: 4),
                                                Container(width: 16, height: 4, decoration: BoxDecoration(color: const Color(0xFFFFC824), borderRadius: BorderRadius.circular(2))),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            "m",
                                            style: GoogleFonts.nunito(
                                              color: const Color(0xFF6BCC5E),
                                              fontWeight: FontWeight.w800,
                                              fontSize: 52,
                                              height: 0.9,
                                              letterSpacing: -2.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 34,
                                          height: 0.85,
                                          letterSpacing: -1.0,
                                        ),
                                        children: const [
                                          TextSpan(text: "gels", style: TextStyle(color: Color(0xFF6BCC5E))),
                                          TextSpan(text: "i", style: TextStyle(color: Color(0xFFFFC824))),
                                          TextSpan(text: "n", style: TextStyle(color: Color(0xFF6BCC5E))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Sağ: Bildirim
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NotificationsPage(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 34),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
                                          child: const Text("3", style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Orta: Adres Çubuğu
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))
                              ],
                            ),
                            child: const HomeAddressBar(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          color: AppColors.background,
                          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                          child: Column(
                            children: [
                              // 🔍 ARAMA MODU: Sadece ürünler ve dükkanlar
                              if (_searchQuery.isNotEmpty) ...[
                                if (_currentDisplayedRestaurants.isEmpty && _currentMatchedFoods.isEmpty)
                                  HomeEmptyState(onRetry: _loadData)
                                else ...[
                                  if (_currentMatchedFoods.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: const Text(
                                          "Eşleşen Ürünler",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: _currentMatchedFoods.length,
                                        itemBuilder: (context, index) {
                                          final item = _currentMatchedFoods[index];
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
                                  if (_currentDisplayedRestaurants.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: const Text(
                                          "Eşleşen Restoranlar",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
                                        ),
                                      ),
                                    ),
                                    RestaurantGrid(restaurants: _currentDisplayedRestaurants),
                                  ],
                                ],
                              ],

                              // 🏠 ANA SAYFA MODU: Banner, Kategori, Fırsatlar
                              if (_searchQuery.isEmpty) ...[
                                BannerSlider(
                                  campaigns: _campaigns,
                                  restaurants: _getRegionFilteredRestaurants(allRestaurants),
                                  onRestaurantSelected: _navigateToRestaurant,
                                  onCategorySelected: _filterByCategory,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      langProvider.translate('categories') == 'categories' ? "Kategoriler" : langProvider.translate('categories'),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.5),
                                    ),
                                  ),
                                ),

                                CategoryList(
                                  topCategories: _topCategories,
                                  onCategorySelected: (cat) => _filterByCategory(cat),
                                ),

                                const SizedBox(height: 12),

                                if (_currentDisplayedRestaurants.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: HomeEmptyState(onRetry: _loadData),
                                  )
                                else ...[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          langProvider.translate('highlights'),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.5),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AllRestaurantsPage(restaurants: _currentDisplayedRestaurants),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Ählisi (${_currentDisplayedRestaurants.length})",
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  HorizontalRestaurantList(restaurants: _currentDisplayedRestaurants),
                                  
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          langProvider.translate('cheapest'),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.5),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final cheapestList = _currentMatchedFoods.isNotEmpty ? _currentMatchedFoods : cheapestFoods.where((f) => _currentDisplayedRestaurants.any((r) => r.id == f.restaurantId)).toList();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AllFoodsPage(foods: cheapestList),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Ählisi (${_currentMatchedFoods.isNotEmpty ? _currentMatchedFoods.length : cheapestFoods.where((f) => _currentDisplayedRestaurants.any((r) => r.id == f.restaurantId)).length})",
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  HorizontalFoodList(
                                    items: _currentMatchedFoods.isNotEmpty ? _currentMatchedFoods : cheapestFoods.where((f) => _currentDisplayedRestaurants.any((r) => r.id == f.restaurantId)).toList(),
                                    onItemTap: (item) => _navigateToRestaurant(item.restaurantId),
                                  ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        langProvider.translate('restaurants'),
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.5),
                                      ),
                                    ),
                                  ),
                                  RestaurantGrid(restaurants: _currentDisplayedRestaurants),
                                ],
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
