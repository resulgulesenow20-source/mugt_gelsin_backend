import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Artık navigasyon AuthWrapper tarafından lib/main.dart içinde yönetiliyor.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6900), // Referans resimdeki canlı turuncu
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 4),
                // Logo Alanı (Animasyonlu)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: -200, end: 0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutBack,
                  builder: (context, translateValue, child) {
                    return Transform.translate(
                      offset: Offset(translateValue, 0),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 2 * 3.141592653589793), // Tam bir tur (360 derece = 2pi)
                        duration: const Duration(seconds: 4), // 4 saniyede döner
                        builder: (context, rotationValue, child) {
                          return Transform.rotate(
                            angle: rotationValue, // Kuryeyi döndürür
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                'assets/images/logo_m.png',
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "MUGT GELSİN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Lezzet Kapınızda",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(flex: 1),
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
