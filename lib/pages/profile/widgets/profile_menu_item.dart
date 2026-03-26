import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';

import 'package:mugut_gelsin/presentation/common/widgets/hover_wrapper.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;
  final Color? color;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = isLogout ? Colors.red : (color ?? AppColors.textPrimary);

    return HoverWrapper(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: themeColor,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isLogout ? Colors.red : AppColors.textPrimary,
            ),
          ),
          trailing: isLogout
              ? null
              : Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 24),
        ),
      ),
    );
  }
}

