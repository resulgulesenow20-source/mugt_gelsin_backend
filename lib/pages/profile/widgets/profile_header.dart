import 'package:flutter/material.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 20, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "Kullanıcı Adı",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text("kullanici@mail.com", style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
