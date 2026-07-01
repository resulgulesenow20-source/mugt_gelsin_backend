import 'package:flutter/material.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/pages/restaurant/restaurant_detail_page.dart';
import 'package:mugut_gelsin/models/campaign_model.dart';

class VerticalRestaurantCard extends StatelessWidget {
  final Restaurant res;
  final List<Campaign> campaigns;
  final double? distance; // Mesafe bilgisini almak için

  const VerticalRestaurantCard({
    super.key,
    required this.res,
    this.campaigns = const [],
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    // Rastgele sahte yorum sayısı ve tag'ler
    final reviewCount = (100 + res.id.hashCode % 9000).toString() + "+";
    final List<String> tags = campaigns.take(2).map((c) => c.title).toList();
    if (tags.isEmpty) {
      tags.add("Sana Özel - %20 İndirim!");
      tags.add("Yıldız Restoran");
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(restaurant: res),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sol: Resim
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          res.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: AppColors.primary.withOpacity(0.2),
                            child: const Icon(Icons.restaurant, color: AppColors.primary),
                          ),
                        ),
                        if (!res.isOpen)
                          Container(
                            width: 80,
                            height: 80,
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: const Text(
                              "KAPALI",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sağ: Bilgiler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Satır 1: İsim ve Yıldız
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                res.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFF673AB7), size: 14), // Getir tarzı mor yıldız
                                const SizedBox(width: 4),
                                Text(
                                  res.rating,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: Color(0xFF673AB7),
                                  ),
                                ),
                                Text(
                                  " ($reviewCount)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Satır 2: Mesafe
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey.shade600, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              distance != null ? "${distance!.toStringAsFixed(1)} km" : "2.4 km", // Dummy mesafe
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Satır 3: Teslimat Süresi ve Min Tutar
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50), // Getir yeşili
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "R",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Min ${res.minOrderAmount} TMT",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Kampanya Tag'leri (Yatay Scroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: tags.map((tag) {
                    final isYellow = tag.contains("İndirim");
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isYellow ? const Color(0xFFFFE000) : Colors.grey.shade100, // Getir sarısı veya açık gri
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isYellow ? Icons.local_offer : Icons.star,
                            size: 12,
                            color: isYellow ? const Color(0xFF673AB7) : Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tag,
                            style: TextStyle(
                              color: isYellow ? const Color(0xFF673AB7) : Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
