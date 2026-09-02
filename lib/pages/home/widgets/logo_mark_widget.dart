import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';

class LogoMarkWidget extends StatelessWidget {
  final double size;
  final Color? color;
  
  const LogoMarkWidget({super.key, this.size = 44, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.75, // Aspect ratio of the SVG
      child: CustomPaint(
        painter: _LogoMarkPainter(color: color),
      ),
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  final Color? color;

  _LogoMarkPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // We will draw in a 200x150 coordinate system and scale to the widget's size.
    final double scaleX = size.width / 200;
    final double scaleY = size.height / 150;
    
    canvas.scale(scaleX, scaleY);
    
    // Orange elements
    final orangePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    // Top horizontal pill
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(10, 50, 30, 20), const Radius.circular(10)), 
        orangePaint);
    // Middle horizontal pill
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(25, 80, 25, 20), const Radius.circular(10)), 
        orangePaint);
    // Bottom vertical pill
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(32, 110, 20, 30), const Radius.circular(10)), 
        orangePaint);

    // Green 'm'
    final greenPaint = Paint()
      ..color = color ?? AppColors.primary // Assuming AppColors.primary is the dark green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final mPath = Path();
    
    // Left stem
    mPath.moveTo(85, 55);
    mPath.lineTo(85, 125);

    // First arch
    mPath.moveTo(85, 85);
    mPath.quadraticBezierTo(105, 50, 130, 85);
    mPath.lineTo(130, 125);

    // Second arch
    mPath.moveTo(130, 85);
    mPath.quadraticBezierTo(150, 50, 175, 85);
    mPath.lineTo(175, 125);

    canvas.drawPath(mPath, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
