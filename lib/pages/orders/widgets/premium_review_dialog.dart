import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/models/order_model.dart';
import 'package:mugut_gelsin/providers/order_tracking_provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugut_gelsin/providers/language_provider.dart';

class PremiumReviewDialog extends StatefulWidget {
  final OrderModel order;

  const PremiumReviewDialog({super.key, required this.order});

  @override
  State<PremiumReviewDialog> createState() => _PremiumReviewDialogState();
}

class _PremiumReviewDialogState extends State<PremiumReviewDialog> {
  double _tasteRating = 5;
  double _speedRating = 5;
  double _serviceRating = 5;
  
  final TextEditingController _commentController = TextEditingController();
  final List<String> _selectedTags = [];
  bool _isLoading = false;

  final List<String> _positiveTags = ["Hızlı Geldi", "Lezzetliydi", "Sıcak ve Tazeydi", "Paketleme İyiydi", "Bol Malzemeli"];
  final List<String> _negativeTags = ["Geç Geldi", "Yemek Soğuktu", "Eksik Ürün", "Kötü Paketleme", "Tadı Kötüydü"];

  double get _averageRating => (_tasteRating + _speedRating + _serviceRating) / 3;

  String _getEmoji() {
    if (_averageRating >= 4.5) return "😍";
    if (_averageRating >= 3.5) return "😊";
    if (_averageRating >= 2.5) return "😐";
    if (_averageRating >= 1.5) return "🙁";
    return "😡";
  }

  Color _getRatingColor() {
    if (_averageRating >= 4.0) return Colors.green;
    if (_averageRating >= 2.5) return Colors.orange;
    return Colors.red;
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _submit() async {
    setState(() => _isLoading = true);
    
    final authProvider = context.read<app_auth.AuthProvider>();
    final userId = authProvider.user?.uid ?? "unknown";
    final userName = authProvider.userData?['name'] ?? "Bilinmeyen Kullanıcı";
    
    final provider = context.read<OrderTrackingProvider>();
    bool success = await provider.submitReview(
      order: widget.order,
      userId: userId,
      userName: userName,
      rating: _averageRating,
      tasteRating: _tasteRating,
      speedRating: _speedRating,
      serviceRating: _serviceRating,
      comment: _commentController.text.trim(),
      tags: _selectedTags,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harika! Değerlendirmeniz için teşekkürler! 🎉"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hata oluştu, lütfen tekrar deneyin."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildRatingRow(String title, double rating, Function(double) onRatingChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              iconSize: 32,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
              ),
              onPressed: () => onRatingChanged(index + 1.0),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                _getEmoji(),
                style: const TextStyle(fontSize: 50),
              ),
              const SizedBox(height: 12),
              Text(
                langProvider.translate('how_was_it'),
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${widget.order.shopName} ${langProvider.translate('nav_orders')}",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Ratings
              _buildRatingRow(langProvider.translate('taste'), _tasteRating, (r) => setState(() => _tasteRating = r)),
              const SizedBox(height: 12),
              _buildRatingRow(langProvider.translate('speed'), _speedRating, (r) => setState(() => _speedRating = r)),
              const SizedBox(height: 12),
              _buildRatingRow(langProvider.translate('service'), _serviceRating, (r) => setState(() => _serviceRating = r)),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Tags
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  langProvider.translate('highlights'),
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._positiveTags.map((tag) => _buildTagChip(tag, isPositive: true)),
                  ..._negativeTags.map((tag) => _buildTagChip(tag, isPositive: false)),
                ],
              ),

              const SizedBox(height: 24),

              // Comment
              TextField(
                controller: _commentController,
                maxLines: 3,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  hintText: langProvider.translate('write_review'),
                  hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.surfaceSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        langProvider.translate('later'),
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getRatingColor(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              langProvider.translate('send').toUpperCase(),
                              style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag, {required bool isPositive}) {
    final isSelected = _selectedTags.contains(tag);
    return GestureDetector(
      onTap: () => _toggleTag(tag),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1))
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? (isPositive ? Colors.green : Colors.red)
                : Colors.grey.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Text(
          tag,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected 
                ? (isPositive ? Colors.green : Colors.red)
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
