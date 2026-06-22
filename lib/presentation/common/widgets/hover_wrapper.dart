import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';

class HoverWrapper extends StatefulWidget {
  final Widget child;
  final double hoverElevation;
  final double normalElevation;

  const HoverWrapper({
    super.key,
    required this.child,
    this.hoverElevation = 12,
    this.normalElevation = 0,
  });

  @override
  State<HoverWrapper> createState() => _HoverWrapperState();
}

class _HoverWrapperState extends State<HoverWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isHovered 
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ]
            : AppColors.softShadow,
        ),
        child: widget.child,
      ),
    );
  }
}

