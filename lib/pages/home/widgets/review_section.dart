import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugut_gelsin/models/review_model.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';

class ReviewSection extends StatefulWidget {
  final String restaurantId;
  final String? docId;
  const ReviewSection({super.key, required this.restaurantId, this.docId});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> with AutomaticKeepAliveClientMixin<ReviewSection> {
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 5.0;
  int _currentPage = 0;
  late ScrollController _scrollController;
  Stream<QuerySnapshot>? _reviewsStream;
  bool _hasValidIds = false;
  List<QueryDocumentSnapshot>? _cachedDocs;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

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
    } else {
      _hasValidIds = false;
    }
  }

  @override
  void didUpdateWidget(covariant ReviewSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurantId != widget.restaurantId || oldWidget.docId != widget.docId) {
      _currentPage = 0;
      _cachedDocs = null;
      _scrollController.removeListener(_onScroll);
      _scrollController.dispose();
      _scrollController = ScrollController();
      _scrollController.addListener(_onScroll);

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
      } else {
        _hasValidIds = false;
        _reviewsStream = null;
      }
      updateKeepAlive();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final currentScroll = _scrollController.position.pixels;
    final itemWidth = MediaQuery.of(context).size.width * 0.85;
    int page = (currentScroll / itemWidth).round();
    if (page < 0) page = 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  void _showCommentSheet() {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yorum yapmak için lütfen giriş yapın.")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Puanınız ve Yorumunuz",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Yıldızlı Puanlama
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _userRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setModalState(() {
                          _userRating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Düşüncelerinizi yazın...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isSubmitting ? null : () async {
                      if (_commentController.text.isNotEmpty) {
                        setModalState(() {
                          isSubmitting = true;
                        });

                        try {
                          final customerName = authProvider.userData?['name'] ?? "Bilinmeyen Kullanıcı";
                          final rating = _userRating.toInt();
                          final comment = _commentController.text.trim();

                          final reviewData = {
                            'userId': authProvider.user?.uid ?? '',
                            'userName': customerName,
                            'user_name': customerName,
                            'customerName': customerName,
                            'restaurantId': widget.restaurantId,
                            'shop_id': widget.restaurantId,
                            'rating': rating,
                            'comment': comment,
                            'createdAt': FieldValue.serverTimestamp(),
                            'timestamp': FieldValue.serverTimestamp(),
                          };

                          // Write directly to both collections
                          await FirebaseFirestore.instance.collection('Yorumlar').add(reviewData);
                          await FirebaseFirestore.instance.collection('Reviews').add(reviewData);

                          _commentController.clear();
                          _userRating = 5.0;
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Yorumunuz başarıyla gönderildi.")),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Yorum gönderilemedi: $e")),
                            );
                          }
                        } finally {
                          setModalState(() {
                            isSubmitting = false;
                          });
                        }
                      }
                    },
                    child: isSubmitting 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Yorumu Gönder", style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsList(List<QueryDocumentSnapshot> docs) {
    final list = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data;
    }).toList();
    
    // Sort in memory descending
    list.sort((a, b) {
      final tA = a['createdAt'] ?? a['timestamp'];
      final tB = b['createdAt'] ?? b['timestamp'];
      if (tA is Timestamp && tB is Timestamp) {
        return tB.compareTo(tA);
      }
      return 0;
    });

    // Make sure we clamp page tracker index within bounds if lists shrink
    if (_currentPage >= list.length) {
      _currentPage = 0;
    }

    return Column(
      children: [
        SizedBox(
          height: 270,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final reviewData = list[index];
              final review = Review.fromMap(reviewData);
              final isSelected = _currentPage == index;

              return AnimatedScale(
                scale: isSelected ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: _buildReviewCard(context, review),
                ),
              );
            },
          ),
        ),
        if (list.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(list.length, (index) {
              final isSelected = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: isSelected ? 18 : 6,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Müşteri Yorumları",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (!_hasValidIds)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Henüz yorum yapılmamış. İlk yorumu sen yap!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          StreamBuilder<QuerySnapshot>(
            stream: _reviewsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Yorumlar yüklenirken hata oluştu: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                );
              }

              if (snapshot.hasData) {
                _cachedDocs = snapshot.data!.docs;
              }

              if (_cachedDocs == null) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                }
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Henüz yorum yapılmamış. İlk yorumu sen yap!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final docs = _cachedDocs!;

              if (docs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Henüz yorum yapılmamış. İlk yorumu sen yap!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return _buildReviewsList(docs);
            },
          ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
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
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${review.timestamp.day}.${review.timestamp.month}.${review.timestamp.year}",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Detaylı Puanlar (Küçük)
          Row(
            children: [
              _buildSmallRatingItem("Lezzet", review.tasteRating),
              const SizedBox(width: 8),
              _buildSmallRatingItem("Hız", review.speedRating),
              const SizedBox(width: 8),
              _buildSmallRatingItem("Servis", review.serviceRating),
            ],
          ),
          const SizedBox(height: 8),

          Expanded(
            child: Text(
              review.comment,
              maxLines: review.orderedItems.isNotEmpty ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
          ),
          
          if (review.reply != null && review.reply!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        Provider.of<LanguageProvider>(context, listen: false).translate('restaurant_reply'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.reply!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (review.orderedItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: review.orderedItems.map((item) {
                  final name = item['name']?.toString() ?? '';
                  final imageUrl = item['imageUrl']?.toString() ?? item['image_url']?.toString() ?? '';
                  final qty = item['quantity'] ?? 1;

                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                               child: const Center(
                                 child: SizedBox(
                                   width: 14,
                                   height: 14,
                                   child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                                 ),
                               ),
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
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: review.tags.map((tag) => Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                )).toList(),
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
        Text("$label:", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(0), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

