import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:mugut_gelsin/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mugut_gelsin/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  VideoPlayerController? _controller;
  bool _isMediaInitialized = false;
  bool _isImage = false;
  bool _isLottie = false;
  String? _mediaUrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _checkDynamicSplash();
  }

  Future<void> _checkDynamicSplash() async {
    try {
      // 3 saniye içinde Firebase'den cevap alamazsak yerel videoya geç
      final docSnapshot = await FirebaseFirestore.instance
          .collection('AppConfig')
          .doc('SplashScreen')
          .get()
          .timeout(const Duration(seconds: 3));

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final String? url = data['url'];
        final String? type = data['type'];

        if (url != null && url.isNotEmpty) {
          final lowerUrl = url.toLowerCase();
          if (type == 'image' || lowerUrl.contains('.png') || lowerUrl.contains('.jpg') || lowerUrl.contains('.jpeg') || lowerUrl.contains('.gif')) {
            _showMedia(url, isImage: true);
            return;
          } else if (type == 'lottie' || lowerUrl.contains('.json') || lowerUrl.contains('.lottie')) {
            _showMedia(url, isLottie: true);
            return;
          } else if (type == 'video' || lowerUrl.contains('.mp4') || lowerUrl.contains('.mov')) {
            await _initVideo(url, isNetwork: true);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Dynamic splash fetch error: $e");
    }
    
    // Fallback: Herhangi bir hata veya timeout durumunda yerel videoyu aç
    await _initVideo('assets/videos/animasyon.mp4', isNetwork: false);
  }

  void _showMedia(String url, {bool isImage = false, bool isLottie = false}) {
    if (!mounted) return;
    setState(() {
      _isImage = isImage;
      _isLottie = isLottie;
      _mediaUrl = url;
      _isMediaInitialized = true;
    });

    // Resmi en az 3.5 saniye göster, aynı zamanda verileri ve Auth'u arkaplanda önyükle
    Future.wait([
      Future.delayed(const Duration(milliseconds: 3500)),
      ApiService().fetchRestaurants(),
      ApiService().fetchCampaigns(),
      Future.doWhile(() async {
        if (!mounted) return false;
        if (context.read<app_auth.AuthProvider>().isInitialized) return false;
        await Future.delayed(const Duration(milliseconds: 100));
        return true;
      }),
    ]).then((_) {
      _navigateToMain();
    });
  }

  Future<void> _initVideo(String path, {required bool isNetwork}) async {
    if (isNetwork) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(path));
    } else {
      _controller = VideoPlayerController.asset(path);
    }
    
    try {
      await _controller!.initialize();
      if (!mounted) return;
      
      setState(() {
        _isMediaInitialized = true;
      });
      
      _controller!.setVolume(1.0); // Ses açık
      _controller!.play();

      _controller!.addListener(() async {
        if (_controller!.value.isInitialized && _controller!.value.position >= _controller!.value.duration) {
          _controller!.removeListener(() {}); // Prevent multiple calls
          await Future.wait([
            ApiService().fetchRestaurants(),
            ApiService().fetchCampaigns(),
            Future.doWhile(() async {
              if (!mounted) return false;
              if (context.read<app_auth.AuthProvider>().isInitialized) return false;
              await Future.delayed(const Duration(milliseconds: 100));
              return true;
            }),
          ]);
          _navigateToMain();
        }
      });
    } catch (e) {
      debugPrint("Video initialization error: $e");
      _navigateToMain();
    }
  }

  void _navigateToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFFF6B00), // Match the logo's orange
      body: Center(
        child: _isMediaInitialized
            ? _isLottie
                ? SizedBox.expand(
                    child: Lottie.network(
                      _mediaUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        if (mounted) {
                          Future.microtask(() => _navigateToMain());
                        }
                        return const SizedBox();
                      },
                    ),
                  )
                : _isImage
                    ? SizedBox.expand(
                        child: Image.network(
                          _mediaUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            if (mounted) {
                              Future.microtask(() => _navigateToMain());
                            }
                            return const SizedBox();
                          },
                        ),
                      )
                    : SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                      )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
