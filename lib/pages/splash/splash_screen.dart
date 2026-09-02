import 'package:flutter/material.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:mugut_gelsin/pages/main_screen.dart' as mugut_main;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const mugut_main.MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF533EB9), // Mor arka plan rengi yedeği
          image: DecorationImage(
            image: AssetImage('assets/images/splash_logo.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}


