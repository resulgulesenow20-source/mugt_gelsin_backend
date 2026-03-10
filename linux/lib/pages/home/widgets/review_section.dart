import 'package:flutter/material.dart';

// Bu sınıf sadece yorumlar bölümünden sorumlu olacak
class ReviewSection extends StatefulWidget {
  const ReviewSection({super.key});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  // Kullanıcının yazdığı yazıyı kontrol eden yardımcı
  final TextEditingController _commentController = TextEditingController();

  // Yorumların tutulduğu liste
  List<Map<String, String>> reviews = [
    {"user": "Ahmet Y.", "rating": "5.0", "comment": "Hızlı geldi, sıcaktı."},
    {"user": "Ayşe K.", "rating": "4.5", "comment": "Hamuru harikaydı."},
  ];

  // Alttan açılan yorum yapma penceresi
  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Yorum Yap",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: "Düşüncelerinizi yazın...",
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_commentController.text.isNotEmpty) {
                  setState(() {
                    reviews.insert(0, {
                      "user": "Yeni Kullanıcı",
                      "rating": "5.0",
                      "comment": _commentController.text,
                    });
                  });
                  _commentController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Gönder"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Müşteri Yorumları",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _showCommentSheet,
              child: const Text("Yorum Yap"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return _buildReviewCard(
                reviews[index]["user"]!,
                reviews[index]["rating"]!,
                reviews[index]["comment"]!,
              );
            },
          ),
        ),
      ],
    );
  }

  // Yorum kutucuğu tasarımı
  Widget _buildReviewCard(String user, String rating, String comment) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(comment, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
