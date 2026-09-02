import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyOfferWidget extends StatelessWidget {
  final VoidCallback onTap;

  const DailyOfferWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF5D3EBC), // Dark green background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_offer_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "GÜNÜN TEKLİFİ",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Iň gowy tagamlar\niň gowy bahada!",
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 10,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "GÖR",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF5D3EBC), // Purple
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_rounded, color: Color(0xFF5D3EBC), size: 12),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Color(0xFFFFD500),
              size: 56,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
