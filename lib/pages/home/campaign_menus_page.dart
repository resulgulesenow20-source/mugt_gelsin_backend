import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/models/campaign_model.dart';
import 'package:mugut_gelsin/presentation/common/cards/food_card.dart';
import 'package:mugut_gelsin/pages/restaurant/restaurant_detail_page.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';

class CampaignMenusPage extends StatelessWidget {
  final List<Restaurant> restaurants;

  const CampaignMenusPage({super.key, required this.restaurants});

  Restaurant? _getRestaurantById(String id) {
    try {
      return restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final String title = langProvider.get('campaigns'); // "Kampanyalar"

    // Restoran menülerinden kampanyalı veya indirimli (oldPrice > price) olan tüm yemekleri topla
    final List<FoodWithRestaurant> campaignFoods = [];
    for (var res in restaurants) {
      for (var food in res.menu) {
        if (food.isCampaign || (food.oldPrice != null && food.oldPrice! > food.price)) {
          campaignFoods.add(FoodWithRestaurant(
            food: food,
            restaurantId: res.id,
            restaurantName: res.name,
            minOrderAmount: res.minOrderAmount,
            restaurantIsOpen: res.isOpen,
          ));
        }
      }
    }

    final String tabBanners = langProvider.selectedLang == 'TR'
        ? "Restoran Fırsatları"
        : (langProvider.selectedLang == 'TM' ? "Restoran Teklipleri" : "Акции ресторанов");

    final String tabFoods = langProvider.selectedLang == 'TR'
        ? "Kampanyalı Yemekler"
        : (langProvider.selectedLang == 'TM' ? "Aksiýaly Tagamlar" : "Блюда по акции");

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w900,
              color: Colors.black,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: tabBanners),
              Tab(text: tabFoods),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Kampanyalı/Reklamlı Restoranlar
            _buildBannersTab(context, langProvider),

            // TAB 2: Kampanyalı/İndirimli Menü ve Yemekler
            _buildFoodsTab(context, campaignFoods, langProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildBannersTab(BuildContext context, LanguageProvider langProvider) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Kampanyalar')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  langProvider.translate('no_fav_res'),
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        final campaigns = snapshot.data!.docs
            .map((doc) => Campaign.fromFirestore(doc))
            .toList();

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: campaigns.length,
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
            final restaurant = _getRestaurantById(campaign.shopId);

            return _buildCampaignCard(context, campaign, restaurant, langProvider);
          },
        );
      },
    );
  }

  Widget _buildFoodsTab(
    BuildContext context,
    List<FoodWithRestaurant> campaignFoods,
    LanguageProvider langProvider,
  ) {
    if (campaignFoods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.discount_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              langProvider.selectedLang == 'TR'
                  ? "Şu anda kampanyalı menü bulunmuyor."
                  : (langProvider.selectedLang == 'TM'
                      ? "Häzirki wagtda aksiýaly tagam ýok."
                      : "В настоящее время нет акционных блюд."),
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: campaignFoods.length,
      itemBuilder: (context, index) {
        final item = campaignFoods[index];
        final restaurant = _getRestaurantById(item.restaurantId);

        return FoodCard(
          food: item.food,
          restaurantId: item.restaurantId,
          restaurantName: item.restaurantName,
          minOrderAmount: item.minOrderAmount,
          restaurantIsOpen: restaurant?.isOpen ?? true,
        );
      },
    );
  }

  Widget _buildCampaignCard(
    BuildContext context,
    Campaign campaign,
    Restaurant? restaurant,
    LanguageProvider langProvider,
  ) {
    final String discountText = campaign.type == 'percentage'
        ? "%${campaign.value.toInt()} İndirim"
        : "${campaign.value.toInt()} TMT İndirim";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Resmi
            if (campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty)
              Stack(
                children: [
                  Image.asset(
                    campaign.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      if (campaign.imageUrl!.startsWith('http')) {
                        return Image.network(
                          campaign.imageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        );
                      }
                      return _buildPlaceholder();
                    },
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        discountText,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              _buildPlaceholder(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve Açıklama
                  Text(
                    campaign.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    campaign.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  // Kupon Kodu Bölümü (Varsa)
                  if (campaign.code != null && campaign.code!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.blueGrey.withOpacity(0.2),
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.confirmation_number_outlined, size: 16, color: Colors.blueGrey),
                              const SizedBox(width: 8),
                              Text(
                                "KOD: ${campaign.code}",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Kupon kodu kopyalandı!"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Text(
                              "Kopyala",
                              style: GoogleFonts.inter(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 24, thickness: 1),

                  // Dükkan Bilgisi ve Git Butonu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              size: 18,
                              color: campaign.shopId.isEmpty ? Colors.blue : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                campaign.shopId.isEmpty
                                    ? 'Sistem Genelinde (Tüm Restoranlar)'
                                    : (restaurant?.name ?? 'mugut Gelsin Restoranı'),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (restaurant != null)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailPage(restaurant: restaurant),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          child: Text(
                            "İncele",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.orange.shade100,
      child: Center(
        child: Icon(Icons.campaign_outlined, size: 48, color: Colors.orange.shade400),
      ),
    );
  }
}
