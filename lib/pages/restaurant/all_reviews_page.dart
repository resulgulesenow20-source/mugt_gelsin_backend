import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mugut_gelsin/models/review_model.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';

class AllReviewsPage extends StatefulWidget {
  final String restaurantId;
  final String? docId;
  final String restaurantName;

  const AllReviewsPage({
    super.key,
    required this.restaurantId,
    this.docId,
    required this.restaurantName,
  });

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  Stream<QuerySnapshot>? _reviewsStream;
  bool _hasValidIds = false;

  @override
  void initState() {
    super.initState();
    final List<String> validIds = [
      widget.restaurantId,
      if (widget.docId != null && widget.docId!.isNotEmpty) widget.docId!,
    ].where((id) => id.trim().isNotEmpty).toSet().toList();

    if (validIds.isNotEmpty) {
      _hasValidIds = true;
      _reviewsStream = FirebaseFirestore.instance
          .collection('Yorumlar')
          .where(
            Filter.or(
              Filter('shopId', whereIn: validIds),
              Filter('shop_id', whereIn: validIds),
              Filter('restaurantId', whereIn: validIds),
            ),
          )
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.restaurantName.isNotEmpty ? "Tüm Yorumlar (${widget.restaurantName})" : "Tüm Yorumlar",
          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFC4E193), Color(0xFF56AA86)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: !_hasValidIds
          ? const Center(child: Text("Yorum bulunamadı."))
          : StreamBuilder<QuerySnapshot>(
              stream: _reviewsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Hata: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF56AA86)));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Henüz yorum yapılmamış.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final list = docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
                list.sort((a, b) {
                  final tA = a['createdAt'] ?? a['timestamp'];
                  final tB = b['createdAt'] ?? b['timestamp'];
                  if (tA is Timestamp && tB is Timestamp) {
                    return tB.compareTo(tA);
                  }
                  return 0;
                });

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final review = Review.fromMap(list[index]);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildReviewCard(context, review),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${review.timestamp.day}.${review.timestamp.month}.${review.timestamp.year}",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF56AA86).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF56AA86)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildSmallRatingItem("Lezzet", review.tasteRating),
              const SizedBox(width: 8),
              _buildSmallRatingItem("Hız", review.speedRating),
              const SizedBox(width: 8),
              _buildSmallRatingItem("Servis", review.serviceRating),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            review.comment,
            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
          ),
          
          if (review.reply != null && review.reply!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF56AA86).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF56AA86).withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_rounded, size: 16, color: Color(0xFF56AA86)),
                      const SizedBox(width: 6),
                      Text(
                        Provider.of<LanguageProvider>(context, listen: false).translate('restaurant_reply'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF56AA86),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.reply!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (review.orderedItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: review.orderedItems.map((item) {
                  final name = item['name']?.toString() ?? '';
                  final imageUrl = item['imageUrl']?.toString() ?? item['image_url']?.toString() ?? '';
                  final qty = item['quantity'] ?? 1;

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (imageUrl.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 36,
                                height: 36,
                                color: Colors.grey.shade100,
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 36,
                                height: 36,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.fastfood_rounded, size: 18, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ] else ...[
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.fastfood_rounded, size: 18, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          "$qty x $name",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallRatingItem(String label, double rating) {
    if (rating == 0) return const SizedBox();
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        Text(
          rating.toStringAsFixed(0),
          style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
