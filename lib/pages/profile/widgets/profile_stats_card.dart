import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';

class ProfileStatsCard extends StatelessWidget {
  final double balance;
  final int points;
  final int activeOrders;

  const ProfileStatsCard({
    super.key,
    required this.balance,
    required this.points,
    required this.activeOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gazanan TMT",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "gazandygýñ tmt lary sargytlarda peýdalan",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on_outlined, color: AppColors.accent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "${balance.toInt()} TMT",
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressBar(balance),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double currentBalance) {
    final List<int> steps = [10, 20, 30, 50];
    final double maxStep = 50.0;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Track width takes into account the circle size (36) so centers align.
        final double circleSize = 36.0;
        final double trackWidth = constraints.maxWidth - circleSize;
        final double fillPercentage = (currentBalance.clamp(0, maxStep) / maxStep);
        
        return SizedBox(
          height: circleSize,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background Track
              Positioned(
                left: circleSize / 2,
                right: circleSize / 2,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Active Track
              Positioned(
                left: circleSize / 2,
                child: Container(
                  height: 6,
                  width: trackWidth * fillPercentage,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Step Markers
              ...steps.map((step) {
                bool isReached = currentBalance >= step;
                double leftPosition = trackWidth * (step / maxStep);
                return Positioned(
                  left: leftPosition,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isReached ? AppColors.accent : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isReached ? AppColors.accent : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      step.toString(),
                      style: TextStyle(
                        color: isReached ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }
    );
  }
}
