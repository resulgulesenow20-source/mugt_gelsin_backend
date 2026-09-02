import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';

class CustomSearchField extends StatelessWidget {
  final Function(String) onChanged;
  final String hintText;

  const CustomSearchField({
    super.key,
    required this.onChanged,
    this.hintText = "Arama yapın...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF5D3EBC), size: 20),
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

