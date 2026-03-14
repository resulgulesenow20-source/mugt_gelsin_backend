import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mugt_gelsin/core/constants/app_colors.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _bannerData = [
    {'image': 'assets/images/banner_user.jpg', 'title': 'Mugt Gelsin Keyfi', 'desc': 'yüreğinde rahatlyk her demde MUGT sade we lezzetli'},
    {'image': 'assets/images/banner_1.png', 'title': 'Gurme Burgerler', 'desc': '%20 İndirim Fırsatını Kaçırmayın!'},
    {'image': 'assets/images/banner_2.png', 'title': 'Sıcak Pizzalar', 'desc': 'İkinci Pizzada %50 İndirim!'},
    {'image': 'assets/images/banner_3.png', 'title': 'Taze Suşiler', 'desc': 'Uzak Doğu Esintisi Kapınızda.'},
    {'image': 'assets/images/banner_4.png', 'title': 'İtalyan Makarnaları', 'desc': 'Gerçek İtalyan Lezzeti.'},
    {'image': 'assets/images/banner_5.png', 'title': 'Efsane Tatlılar', 'desc': 'Gününüzü Tatlandırın.'},
    {'image': 'assets/images/banner_6.png', 'title': 'Taze Salatalar', 'desc': 'Sağlıklı ve Hafif Seçenekler.'},
    {'image': 'assets/images/banner_7.png', 'title': 'Zengin Kahvaltı', 'desc': 'Güne Güzel Bir Başlangıç Yapın.'},
    {'image': 'assets/images/banner_8.png', 'title': 'Nisbet Kebap', 'desc': 'Gerçek Kebap Keyfi Burada.'},
    {'image': 'assets/images/banner_9.png', 'title': 'Serinleten Dondurma', 'desc': 'Her Mevsim Ferahlık.'},
    {'image': 'assets/images/banner_10.png', 'title': 'Özel Kahveler', 'desc': 'Kahve Molanız Keyfe Dönüşsün.'},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _bannerData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _bannerData.length,
            itemBuilder: (context, index) {
              return _buildBannerItem(_bannerData[index]);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerData.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == index 
                  ? AppColors.primary 
                  : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(Map<String, String> data) {
    return AnimatedScale(
      scale: _currentPage == _bannerData.indexOf(data) ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Image Background
              Positioned.fill(
                child: Image.asset(
                  data['image']!,
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "KAMPANYA",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      data['desc']!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
