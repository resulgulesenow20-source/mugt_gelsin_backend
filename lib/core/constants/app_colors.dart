import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5D3EBC); // Getir Blue/Purple
  static const Color primaryDark = Color(0xFF462E8E);
  static const Color primaryLight = Color(0xFFEBE6F8);
  static const Color accent = Color(0xFF22C55E); // Nice light green
  static const Color secondary = Color(0xFF1A1A1A); // Deeper black for better contrast
  
  // ✅ Lively / Premium UI Colors
  static const Color background = Color(0xFFF4F5F7); // Daha griye yakın modern arka plan rengi
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
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B5DE1), Color(0xFF5D3EBC)],
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
