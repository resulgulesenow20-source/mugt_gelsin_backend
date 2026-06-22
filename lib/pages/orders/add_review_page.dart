import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';

class AddReviewPage extends StatefulWidget {
  final String orderId;
  final String restaurantId;
  final String restaurantName;

  const AddReviewPage({
    super.key,
    required this.orderId,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _orderedItems = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderItems();
  }

  Future<void> _fetchOrderItems() async {
    try {
      final docSnap = await FirebaseFirestore.instance.collection('Emirler').doc(widget.orderId).get();
      if (docSnap.exists) {
        final data = docSnap.data();
        if (data != null && data['items'] is List) {
          setState(() {
            _orderedItems = List<Map<String, dynamic>>.from(
                (data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching order items for review: $e");
    }
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    final lang = context.read<LanguageProvider>();
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final reviewData = {
        'userId': user.uid,
        'userName': user.displayName ?? lang.get('unknown_customer'),
        'user_name': user.displayName ?? lang.get('unknown_customer'),
        'customerName': user.displayName ?? lang.get('unknown_customer'),
        'restaurantId': widget.restaurantId,
        'shop_id': widget.restaurantId,
        'orderId': widget.orderId,
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'orderedItems': _orderedItems,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('Reviews').add(reviewData);
      await FirebaseFirestore.instance.collection('Yorumlar').add(reviewData);

      await FirebaseFirestore.instance
          .collection('Emirler')
          .doc(widget.orderId)
          .update({'isRated': true});

      // Calculate average rating and update restaurant rating in Dukkanlar collection
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Yorumlar')
            .where('shop_id', isEqualTo: widget.restaurantId)
            .get();

        double totalRating = 0;
        int count = 0;

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          final r = double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0;
          if (r > 0) {
            totalRating += r;
            count++;
          }
        }

        // Include the newly added review if it wasn't returned in the snapshot yet
        bool containsNewReview = querySnapshot.docs.any((doc) {
          final data = doc.data();
          return data['orderId'] == widget.orderId;
        });

        if (!containsNewReview) {
          totalRating += _rating;
          count++;
        }

        double averageRating = count > 0 ? totalRating / count : _rating;
        double averageRatingRounded = double.parse(averageRating.toStringAsFixed(1));

        // Update the Dukkanlar document
        final shopDoc = FirebaseFirestore.instance.collection('Dukkanlar').doc(widget.restaurantId);
        final shopSnapshot = await shopDoc.get();
        if (shopSnapshot.exists) {
          await shopDoc.update({'rating': averageRatingRounded});
        } else {
          // Fallback 1: Query by mugut_id
          final shopQuery = await FirebaseFirestore.instance
              .collection('Dukkanlar')
              .where('mugut_id', isEqualTo: widget.restaurantId)
              .get();
          if (shopQuery.docs.isNotEmpty) {
            await shopQuery.docs.first.reference.update({'rating': averageRatingRounded});
          } else {
            // Fallback 2: Query by id
            final shopQuery2 = await FirebaseFirestore.instance
                .collection('Dukkanlar')
                .where('id', isEqualTo: widget.restaurantId)
                .get();
            if (shopQuery2.docs.isNotEmpty) {
              await shopQuery2.docs.first.reference.update({'rating': averageRatingRounded});
            }
          }
        }
      } catch (ratingError) {
        debugPrint("Error updating restaurant average rating: $ratingError");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.get('review_thanks'))),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.get('error_occurred').replaceAll('{error}', e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(lang.get('rate'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFF5F5F7),
              child: Icon(Icons.restaurant, size: 40, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              widget.restaurantName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              lang.get('how_was_order'),
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1.0),
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              "$_rating / 5.0",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            
            const SizedBox(height: 32),
            
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: lang.get('write_review'),
                filled: true,
                fillColor: const Color(0xFFF5F5F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(lang.get('send'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

