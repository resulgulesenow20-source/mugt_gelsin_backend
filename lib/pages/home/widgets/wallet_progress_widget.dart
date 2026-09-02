import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:mugut_gelsin/core/constants/app_colors.dart';

import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart';

class WalletProgressWidget extends StatelessWidget {
  const WalletProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) return const SizedBox.shrink();
    final double balance = auth.walletBalance;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                      "GAZANAN TMT",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF5D3EBC),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Sargyt et, bonus gazan!",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_outlined, color: Color(0xFF22C55E), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${balance.toInt()} TMT",
                      style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(balance),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double currentBalance) {
    final List<int> steps = [10, 20, 30, 50];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF5D3EBC), // Always purple line
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Positioned(
              left: 0,
              child: Container(
                height: 4,
                width: constraints.maxWidth * (currentBalance.clamp(0, 50) / 50),
                decoration: const BoxDecoration(
                  color: Colors.transparent, // Background is already purple
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: steps.map((step) {
                bool isCompleted = step < currentBalance;
                bool isActiveTarget = step >= currentBalance && step == steps.firstWhere((s) => s >= currentBalance, orElse: () => steps.last);
                
                Color bgColor = const Color(0xFF5D3EBC); // Always purple
                Color borderColor = const Color(0xFF5D3EBC);
                Color textColor = Colors.white; // Always white

                return Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: isActiveTarget ? 2.0 : 1.5,
                    ),
                  ),
                  child: Text(
                    step.toString(),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }
    );
  }
}

class CyclingMessageWidget extends StatefulWidget {
  final List<String> messages;
  const CyclingMessageWidget({Key? key, required this.messages}) : super(key: key);

  @override
  State<CyclingMessageWidget> createState() => _CyclingMessageWidgetState();
}

class _CyclingMessageWidgetState extends State<CyclingMessageWidget> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(CyclingMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      _currentIndex = 0;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.messages.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.messages.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) return const SizedBox.shrink();
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.5),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Align(
        key: ValueKey<int>(_currentIndex),
        alignment: Alignment.centerLeft,
        child: Text(
          widget.messages[_currentIndex],
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
