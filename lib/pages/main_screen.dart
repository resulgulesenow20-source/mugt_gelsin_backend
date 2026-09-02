import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/pages/home/home_page.dart';
import 'package:mugut_gelsin/pages/cart/cart_page.dart';
import 'package:mugut_gelsin/pages/profile/profile_page.dart';
import 'package:mugut_gelsin/pages/profile/orders_page.dart';
import 'package:mugut_gelsin/pages/dashboard/dashboard_page.dart'; // Added DashboardPage
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/pages/orders/order_tracking_page.dart';
import 'package:mugut_gelsin/pages/home/widgets/guest_welcome_overlay.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _dashboardNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _ordersNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _homeNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _cartNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavKey = GlobalKey<NavigatorState>();

  // AddToCartAnimation Keys
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  @override
  void initState() {
    super.initState();
    // ✅ Navigasyon sinyallerini dinle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navProvider = context.read<NavigationProvider>();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Uygulama açıldıktan 5 saniye sonra kullanıcı giriş yapmamışsa karşılama ekranını göster
      if (!authProvider.isLoggedIn) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && !authProvider.isLoggedIn) {
            GuestWelcomeOverlay.show(context);
          }
        });
      }

      navProvider.addListener(() {
        if (!mounted) return;
        final orderId = navProvider.orderToTrack;
        if (orderId != null) {
          // Takip sinyalini hemen temizleyelim (tekrar tetiklenmesin)
          navProvider.clearOrderTrackingSignal();
          
          // Siparişler sekmesinin (sekme 1) navigator'ına sayfayı bas
          _ordersNavKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => OrderTrackingPage(orderId: orderId),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final selectedIndex = navProvider.selectedIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final currentKey = _getSelectedNavigatorKey(selectedIndex);
        if (currentKey.currentState?.canPop() ?? false) {
          currentKey.currentState?.pop();
        } else if (selectedIndex != 2) {
          navProvider.setIndex(2);
        }
      },
      child: AddToCartAnimation(
        cartKey: cartKey,
        height: 30,
        width: 30,
        opacity: 0.85,
        dragAnimation: const DragToCartAnimationOptions(
          rotation: true,
        ),
        jumpAnimation: const JumpAnimationOptions(),
        createAddToCartAnimation: (runAddToCartAnimation) {
          this.runAddToCartAnimation = runAddToCartAnimation;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<NavigationProvider>().setAddToCartAnimationFunction(runAddToCartAnimation);
          });
        },
        child: Scaffold(
        extendBody: true, // Allow body to scroll behind floating nav bar
        body: IndexedStack(
          index: selectedIndex,
          children: [
            _buildTabNavigator(_dashboardNavKey, const DashboardPage()),
            _buildTabNavigator(_ordersNavKey, const OrdersPage()),
            _buildTabNavigator(_homeNavKey, const HomePage()),
            _buildTabNavigator(_cartNavKey, const CartPage()),
            _buildTabNavigator(_profileNavKey, const ProfilePage()),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: true,
            child: SizedBox(
              height: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.dashboard, Icons.dashboard_outlined, "Fırsatlar", selectedIndex, navProvider),
                  _buildNavItem(1, Icons.receipt_long, Icons.receipt_long, langProvider.translate('nav_orders'), selectedIndex, navProvider),
                  _buildCenterNavItem(2, selectedIndex, navProvider),
                  _buildNavItem(3, Icons.shopping_cart, Icons.shopping_cart_outlined, langProvider.translate('nav_cart'), selectedIndex, navProvider),
                  _buildNavItem(4, Icons.person, Icons.person_outline, langProvider.translate('nav_profile'), selectedIndex, navProvider),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, int selectedIndex, NavigationProvider navProvider) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 2 && selectedIndex == 2) {
          _homeNavKey.currentState?.popUntil((route) => route.isFirst);
          navProvider.triggerHomeReset();
        } else {
          navProvider.setIndex(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Cart Icon separately for animation
            if (index == 3)
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  final int itemCount = cart.items.fold(0, (sum, item) => sum + item.quantity);
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AddToCartIcon(
                        key: cartKey,
                        icon: Icon(
                          isSelected ? activeIcon : inactiveIcon,
                          color: isSelected ? const Color(0xFFFFD500) : Colors.black87,
                          size: 26,
                        ),
                        badgeOptions: const BadgeOptions(active: false),
                      ),
                      if (itemCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              )
            else if (index == 4)
              CircleAvatar(
                radius: 18,
                backgroundColor: isSelected ? const Color(0xFFFFD500).withOpacity(0.15) : Colors.transparent,
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? const Color(0xFFFFD500) : Colors.black87,
                  size: 24,
                ),
              )
            else
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? const Color(0xFFFFD500) : Colors.black87,
                size: 26,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFFD500) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  GlobalKey<NavigatorState> _getSelectedNavigatorKey(int index) {
    switch (index) {
      case 0: return _dashboardNavKey;
      case 1: return _ordersNavKey;
      case 2: return _homeNavKey;
      case 3: return _cartNavKey;
      case 4: return _profileNavKey;
      default: return _homeNavKey;
    }
  }

  Widget _buildCenterNavItem(int index, int selectedIndex, NavigationProvider navProvider) {
    return GestureDetector(
      onTap: () {
        if (selectedIndex == 2) {
          _homeNavKey.currentState?.popUntil((route) => route.isFirst);
          navProvider.triggerHomeReset();
        } else {
          navProvider.setIndex(2);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.delivery_dining, color: Colors.black, size: 30),
          ),
          const SizedBox(height: 4),
          const Text(
            "Sipariş Ver",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFFD500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigator(GlobalKey<NavigatorState> key, Widget page) {
    return Navigator(
      key: key,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }
}

