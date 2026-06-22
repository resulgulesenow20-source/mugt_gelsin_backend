import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/presentation/common/cards/food_card.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/pages/home/widgets/review_section.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/pages/cart/cart_page.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/services/api_service.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  late Restaurant _currentRestaurant;
  StreamSubscription? _restaurantSub;

  String _getHoursLabel(String langCode) {
    switch (langCode) {
      case 'TM':
        return 'Iş sagatlary';
      case 'RU':
        return 'Часы работы';
      default:
        return 'Çalışma Saatleri';
    }
  }

  @override
  void initState() {
    super.initState();
    _currentRestaurant = widget.restaurant;
    _listenToRestaurant();
  }

  @override
  void dispose() {
    _restaurantSub?.cancel();
    super.dispose();
  }

  void _listenToRestaurant() {
    _restaurantSub?.cancel();
    
    final docId = _currentRestaurant.docId;
    if (docId != null && docId.isNotEmpty) {
      _restaurantSub = FirebaseFirestore.instance
          .collection('Dukkanlar')
          .doc(docId)
          .snapshots()
          .listen((docSnap) {
            if (docSnap.exists) {
              final data = docSnap.data();
              if (data != null && mounted) {
                setState(() {
                  var updated = ApiService().mapFirestoreToRestaurant(data, docSnap.id);
                  if (updated.menu.isEmpty && widget.restaurant.menu.isNotEmpty) {
                    updated = Restaurant(
                      id: updated.id,
                      docId: updated.docId,
                      name: updated.name,
                      imageUrl: updated.imageUrl,
                      rating: updated.rating,
                      deliveryTime: updated.deliveryTime,
                      category: updated.category,
                      minOrderAmount: updated.minOrderAmount,
                      isFavorite: updated.isFavorite,
                      isOpen: updated.isOpen,
                      openingTime: updated.openingTime,
                      closingTime: updated.closingTime,
                      menu: widget.restaurant.menu,
                    );
                  }
                  _currentRestaurant = updated;
                });
              }
            }
          }, onError: (e) {
            debugPrint("Error listening to restaurant detail doc: $e");
          });
    } else {
      _restaurantSub = FirebaseFirestore.instance
          .collection('Dukkanlar')
          .where('id', isEqualTo: _currentRestaurant.id)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final doc = snapshot.docs.first;
              final data = doc.data();
              if (!mounted) return;
              setState(() {
                var updated = ApiService().mapFirestoreToRestaurant(data, doc.id);
                if (updated.menu.isEmpty && widget.restaurant.menu.isNotEmpty) {
                  updated = Restaurant(
                    id: updated.id,
                    docId: updated.docId,
                    name: updated.name,
                    imageUrl: updated.imageUrl,
                    rating: updated.rating,
                    deliveryTime: updated.deliveryTime,
                    category: updated.category,
                    minOrderAmount: updated.minOrderAmount,
                    isFavorite: updated.isFavorite,
                    isOpen: updated.isOpen,
                    openingTime: updated.openingTime,
                    closingTime: updated.closingTime,
                    menu: widget.restaurant.menu,
                  );
                }
                _currentRestaurant = updated;
              });
            }
          }, onError: (e) {
            debugPrint("Error listening to restaurant detail query: $e");
          });
    }
  }

  // Resim yükleme ve hata yönetimi fonksiyonu
  Widget _buildSmartImage(String url, {double? width, double? height}) {
    final cleanUrl = url.trim();
    if (cleanUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: cleanUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) =>
            _errorWidget("Link Bozuk"),
      );
    } else {
      return Image.asset(
        cleanUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorWidget("DOSYA YOK"),
      );
    }
  }

  Widget _errorWidget(String message) {
    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 30),
          Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 10),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header Image with Back Button and Actions
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_rounded, color: AppColors.textPrimary, size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CartPage()),
                          );
                        },
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                          child: Text(
                            context.watch<CartProvider>().items.length.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildSmartImage(
                _currentRestaurant.imageUrl,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Restaurant Info & Menu
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_currentRestaurant.isOpen)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.error.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${langProvider.get('shop_closed_warning')}${(_currentRestaurant.openingTime != null && _currentRestaurant.closingTime != null) ? " (${_getHoursLabel(langProvider.selectedLang)}: ${_currentRestaurant.openingTime} - ${_currentRestaurant.closingTime})" : ""}",
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                   // Info Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentRestaurant.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildInfoChip(Icons.star_rounded, "${_currentRestaurant.rating}", AppColors.warning),
                              const SizedBox(width: 12),
                              _buildInfoChip(Icons.access_time_filled_rounded, _currentRestaurant.deliveryTime, AppColors.primary),
                              const SizedBox(width: 12),
                              _buildInfoChip(
                                Icons.alarm_rounded,
                                "${_currentRestaurant.openingTime ?? '09:00'} - ${_currentRestaurant.closingTime ?? '23:00'}",
                                Colors.blueAccent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(height: 1, color: AppColors.surfaceSubtle),
                  ),

                  // Review Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ReviewSection(
                      restaurantId: _currentRestaurant.id,
                      docId: _currentRestaurant.docId,
                    ),
                  ),

                  // Menu Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      langProvider.translate('highlights'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // Menu List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: _currentRestaurant.menu.length,
                    itemBuilder: (context, index) {
                      final food = _currentRestaurant.menu[index];
                      return FoodCard(
                        food: food,
                        restaurantId: _currentRestaurant.id,
                        restaurantName: _currentRestaurant.name,
                        minOrderAmount: _currentRestaurant.minOrderAmount,
                        restaurantIsOpen: _currentRestaurant.isOpen,
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
