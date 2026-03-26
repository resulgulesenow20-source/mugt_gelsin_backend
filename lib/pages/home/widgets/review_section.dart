import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugut_gelsin/models/review_model.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/services/api_service.dart';

class ReviewSection extends StatefulWidget {
  final String restaurantId;
  const ReviewSection({super.key, required this.restaurantId});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 5.0;
  late Future<List<dynamic>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      _reviewsFuture = ApiService().fetchReviews(widget.restaurantId);
    });
  }

  void _showCommentSheet() {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yorum yapmak iÃ§in lÃ¼tfen giriÅŸ yapÄ±n.")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
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
                "PuanÄ±nÄ±z ve Yorumunuz",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // YÄ±ldÄ±zlÄ± Puanlama
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
                  hintText: "DÃ¼ÅŸÃ¼ncelerinizi yazÄ±n...",
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
                  onPressed: () async {
                    if (_commentController.text.isNotEmpty) {
                      final customerName = authProvider.userData?['name'] ?? "Bilinmeyen KullanÄ±cÄ±";
                      final rating = _userRating.toInt();
                      final comment = _commentController.text;

                      final success = await ApiService().submitReview(widget.restaurantId, {
                        "customerName": customerName,
                        "rating": rating,
                        "comment": comment,
                      });

                      if (success) {
                        _commentController.clear();
                        _userRating = 5.0;
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Yorumunuz baÅŸarÄ±yla gÃ¶nderildi.")),
                          );
                          // Listeyi yenile
                          _loadReviews();
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Yorum gÃ¶nderilemedi. LÃ¼tfen tekrar deneyin.")),
                          );
                        }
                      }
                    }
                  },
                  child: const Text("Yorumu GÃ¶nder", style: TextStyle(color: AppColors.textPrimary)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "MÃ¼ÅŸteri YorumlarÄ±",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _showCommentSheet,
              icon: Icon(Icons.add_comment_outlined, size: 18),
              label: const Text("Yorum Yap"),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<dynamic>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "HenÃ¼z yorum yapÄ±lmamÄ±ÅŸ. Ä°lk yorumu sen yap!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            final reviewsData = snapshot.data!;

            return SizedBox(
              height: 120, // 120 yÃ¼ksekliÄŸe sÄ±ÄŸmasÄ± iÃ§in yorum kartÄ±nÄ±n boyutuna dikkat ediyoruz
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: reviewsData.length,
                itemBuilder: (context, index) {
                  final reviewData = reviewsData[index] as Map<String, dynamic>;
                  final review = Review.fromMap(reviewData);

                  return _buildReviewCard(review);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12, bottom: 8, top: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.orangeGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  review.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  Text(
                    review.rating.toString(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              review.comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

