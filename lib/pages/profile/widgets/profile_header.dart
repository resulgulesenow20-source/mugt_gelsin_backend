import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../edit_profile_page.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userData = authProvider.userData;
    final String name = userData?['name'] ?? "Kullanıcı";
    final String email = userData?['email'] ?? authProvider.user?.phoneNumber ?? "Hesabymy dolandyryň";

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF2B0F6B),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            // Edit Button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfilePage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD500),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Color(0xFF130A2A)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
            color: Color(0xFF130A2A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Hesabymy dolandyryň",
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


