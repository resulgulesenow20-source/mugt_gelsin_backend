import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6900); // ✅ PMS 1505 Orange
  static const Color primaryDark = Color(0xFFE65F00);
  static const Color secondary = Color(0xFFFFB200); // ✅ Golden Sun Yellow
  
  // ✅ Lively / Premium UI Colors
  static const Color background = Color(0xFFF8F9FB); 
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF0F2F5);
  
  static const Color textPrimary = Color(0xFF1A1A1A); 
  static const Color textSecondary = Color(0xFF6E717C); 
  static const Color textTitle = Color(0xFF0D0D0D);

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

  // ✅ Soft Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: const Color(0xFFFF6900).withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
