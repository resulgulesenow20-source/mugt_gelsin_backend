import 'package:flutter/material.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF8533), // Lighter premium orange
              Color(0xFFFF5500), // Brand orange
              Color(0xFFD44400), // Deep rich orange
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 4),
              // Premium Stack with static M logo and passing motor courier
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth > 0 ? constraints.maxWidth : 400.0;
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Centered static M Logo
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: scale.clamp(0.0, 1.0),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                child: Image.asset(
                                  'assets/images/logo_m.png',
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Motorcycle courier passing in front of the M logo from left to right
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: -screenWidth / 2 - 80, end: screenWidth / 2 + 80),
                        duration: const Duration(milliseconds: 2000),
                        curve: Curves.easeInOutCubic,
                        builder: (context, offsetX, child) {
                          return Transform.translate(
                            offset: Offset(offsetX, 40), // Placed slightly lower to pass in front elegantly
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.delivery_dining_rounded,
                            size: 42,
                            color: Color(0xFFFF5500), // Brand orange color
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              // Premium Slide-up + Fade animation for the App Title & Tagline
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 30.0, end: 0.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, translateY, child) {
                  final progress = (30.0 - translateY) / 30.0;
                  return Transform.translate(
                    offset: Offset(0, translateY),
                    child: Opacity(
                      opacity: progress.clamp(0.0, 1.0),
                      child: Column(
                        children: [
                          Text(
                            lang.get('app_name').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lang.get('tagline_splash'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Spacer(flex: 1),
              // Smooth, subtle circular progress indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}


