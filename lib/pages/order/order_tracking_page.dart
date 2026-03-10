import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';
import 'package:mugt_gelsin/services/api_service.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  bool _hasShownReviewDialog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sipariş Takibi"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Emirler')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Sipariş bulunamadı."));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final String status = orderData['status'] ?? 'hazırlanıyor';
          final String shopName = orderData['shop_name'] ?? 'Restoran';
          final String shopId = orderData['shop_id'] ?? 'unknown_shop';
          final String customerName = orderData['customerName'] ?? 'Müşteri';
          final bool isReviewed = orderData['is_reviewed'] == true;
          final List items = orderData['items'] ?? [];

          // Sipariş teslim edildiyse ve daha önce review gösterilmediyse
          if (status == 'teslim edildi' && !isReviewed && !_hasShownReviewDialog) {
            _hasShownReviewDialog = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showReviewDialog(context, shopId, shopName, widget.orderId, customerName);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shopName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sipariş No: ${widget.orderId.substring(0, 8).toUpperCase()}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),
                
                // Takip Stepper
                _buildTrackingStep(
                  title: "Sipariş Alındı",
                  subtitle: "Siparişiniz dükkana iletildi.",
                  icon: Icons.check_circle,
                  isActive: true,
                  isCompleted: true,
                ),
                _buildTrackingLine(true),
                _buildTrackingStep(
                  title: "Hazırlanıyor",
                  subtitle: "Siparişiniz özenle hazırlanıyor.",
                  icon: Icons.restaurant,
                  isActive: status == 'hazırlanıyor' || status == 'yolda' || status == 'yola çıktı' || status == 'teslim edildi',
                  isCompleted: status == 'yolda' || status == 'yola çıktı' || status == 'teslim edildi',
                ),
                _buildTrackingLine(status == 'yolda' || status == 'yola çıktı' || status == 'teslim edildi'),
                _buildTrackingStep(
                  title: "Yolda",
                  subtitle: "Kuryemiz siparişinizi yola çıkardı.",
                  icon: Icons.delivery_dining,
                  isActive: status == 'yolda' || status == 'yola çıktı' || status == 'teslim edildi',
                  isCompleted: status == 'teslim edildi',
                ),
                _buildTrackingLine(status == 'teslim edildi'),
                _buildTrackingStep(
                  title: "Teslim Edildi",
                  subtitle: "Afiyet olsun!",
                  icon: Icons.home,
                  isActive: status == 'teslim edildi',
                  isCompleted: status == 'teslim edildi',
                ),

                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  "Sipariş Verilen Ürünler",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...items.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("${item['quantity']}x ${item['name']}"),
                  trailing: Text("${item['price']} TL"),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReviewDialog(BuildContext context, String shopId, String shopName, String orderId, String customerName) {
    int rating = 5;
    final TextEditingController commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("$shopName'ı Değerlendirin", style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Siparişiniz teslim edildi. Yemek ve hizmet nasıldı?"),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Yorumunuzu buraya yazın (isteğe bağlı)...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () async {
                    // İşaretle ki bir daha çıkmasın
                    await FirebaseFirestore.instance.collection('Emirler').doc(orderId).update({'is_reviewed': true});
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text("Daha Sonra", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: isSubmitting ? null : () async {
                    setDialogState(() => isSubmitting = true);
                    
                    // Backend'e yolla
                    final apiService = ApiService();
                    await apiService.submitReview(shopId, {
                      "customerName": customerName,
                      "rating": rating,
                      "comment": commentController.text.trim(),
                    });

                    // Firestore'da güncelleyelim bir daha çıkmasın
                    await FirebaseFirestore.instance.collection('Emirler').doc(orderId).update({'is_reviewed': true});

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Değerlendirmeniz için teşekkürler!"), backgroundColor: Colors.green),
                      );
                    }
                  },
                  child: isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Gönder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTrackingStep({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color color = isCompleted ? Colors.green : (isActive ? AppColors.textPrimary : Colors.grey[300]!);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(isCompleted ? Icons.check : icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingLine(bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(left: 18),
      height: 30,
      width: 2,
      color: isCompleted ? Colors.green : Colors.grey[200],
    );
  }
}
