import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/models/order_model.dart';
import 'package:mugut_gelsin/providers/order_tracking_provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;

class OrderReviewDialog extends StatefulWidget {
  final OrderModel order;

  const OrderReviewDialog({super.key, required this.order});

  @override
  State<OrderReviewDialog> createState() => _OrderReviewDialogState();
}

class _OrderReviewDialogState extends State<OrderReviewDialog> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir puan (yıldız) seçin.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final authProvider = context.read<app_auth.AuthProvider>();
    final userId = authProvider.user?.uid ?? "unknown";
    final userName = authProvider.userData?['name'] ?? "Bilinmeyen Kullanıcı";
    
    final provider = context.read<OrderTrackingProvider>();
    bool success = await provider.submitReview(
      widget.order,
      userId,
      userName,
      _rating,
      _commentController.text.trim()
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Değerlendirmeniz için teşekkürler! 🎉")),
      );
      Navigator.pop(context); // Close the dialog
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hata oluştu, yorum gönderilemedi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              "Siparişi Değerlendir",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${widget.order.shopName} restoranını değerlendirin",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 40,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Sipariş hakkında ne düşünüyorsunuz? (Opsiyonel)",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("GÖNDER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Vazgeç", style: TextStyle(color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }
}
