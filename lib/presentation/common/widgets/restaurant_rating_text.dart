import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantRatingText extends StatefulWidget {
  final String restaurantId;
  final String? docId;
  final String rating;

  const RestaurantRatingText({
    super.key,
    required this.restaurantId,
    this.docId,
    required this.rating,
  });

  @override
  State<RestaurantRatingText> createState() => _RestaurantRatingTextState();
}

class _RestaurantRatingTextState extends State<RestaurantRatingText> {
  int? _reviewCount;

  @override
  void initState() {
    super.initState();
    _fetchReviewCount();
  }

  Future<void> _fetchReviewCount() async {
    try {
      final List<String> validIds = [
        widget.restaurantId,
        if (widget.docId != null && widget.docId!.isNotEmpty) widget.docId!,
      ].where((id) => id.trim().isNotEmpty).toSet().toList();

      if (validIds.isEmpty) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('Yorumlar')
          .where(
            Filter.or(
              Filter('shopId', whereIn: validIds),
              Filter('shop_id', whereIn: validIds),
              Filter('restaurantId', whereIn: validIds),
            ),
          )
          .count()
          .get();

      if (mounted) {
        setState(() {
          _reviewCount = snapshot.count ?? 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviewCount = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String reviewText = _reviewCount != null ? "($_reviewCount)" : "(...)";
    return Text(
      "${widget.rating} $reviewText",
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.orange, // Made orange as requested
      ),
    );
  }
}
