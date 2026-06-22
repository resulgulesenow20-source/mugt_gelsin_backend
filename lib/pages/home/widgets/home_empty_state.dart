import 'package:flutter/material.dart';
import 'package:mugut_gelsin/presentation/common/buttons/primary_button.dart';

class HomeEmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;
  final String? subMessage;
  final IconData? icon;

  const HomeEmptyState({
    super.key, 
    required this.onRetry,
    this.message,
    this.subMessage,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon ?? Icons.restaurant_menu, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message ?? "Henüz hiç restoran veya yemek yok.",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              subMessage!,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
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

