import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6B00); // More vibrant, energetic orange
  static const Color primaryDark = Color(0xFFE65F00);
  static const Color primaryLight = Color(0xFFFFE0CC);
  static const Color secondary = Color(0xFF1A1A1A); // Deeper black for better contrast
  
  // ✅ Lively / Premium UI Colors
  static const Color background = Color(0xFFF9FAFB); // Cleaner gray-white
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF3F4F6);
  
  // Text Colors
  static const Color textTitle = Color(0xFF111827);
  static const Color textPrimary = Color(0xFF374151);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // ✅ Premium Gradients
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8C00), Color(0xFFFF6900)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, Color(0xFFF8F9FB)],
  );

  // Shadows (Modern Soft UI)
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
  
  static final List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: primary.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
