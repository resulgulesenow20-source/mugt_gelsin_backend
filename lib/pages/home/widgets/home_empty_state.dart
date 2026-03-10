import 'package:flutter/material.dart';
import 'package:mugt_gelsin/presentation/common/buttons/primary_button.dart';

class HomeEmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const HomeEmptyState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Henüz hiç restoran veya yemek yok.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const Text(
            "Python panelinden ekleme yapabilirsiniz.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            onPressed: onRetry,
            text: "Tekrar Dene",
          ),
        ],
      ),
    );
  }
}
