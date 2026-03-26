import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/pages/home/home_page.dart';
import 'package:mugut_gelsin/pages/cart/cart_page.dart';
import 'package:mugut_gelsin/pages/profile/profile_page.dart';
import 'package:mugut_gelsin/pages/profile/orders_page.dart';
import 'package:mugut_gelsin/pages/favorites/favorites_page.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // âœ… Her tab iÃ§in ayrÄ± NavigatorKey tanÄ±mlÄ±yoruz
  final GlobalKey<NavigatorState> _homeNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _favNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _ordersNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _cartNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavKey = GlobalKey<NavigatorState>();

  // AddToCartAnimation Keys
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

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
        } else if (selectedIndex != 0) {
          navProvider.setIndex(0);
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
        extendBody: false, // Body artÄ±k nav barÄ±n arkasÄ±na geÃ§mez, Ã§akÄ±ÅŸma Ã¶nlenir
        body: IndexedStack(
          index: selectedIndex,
          children: [
            _buildTabNavigator(_homeNavKey, const HomePage()),
            _buildTabNavigator(_favNavKey, const FavoritesPage()),
            _buildTabNavigator(_ordersNavKey, const OrdersPage()),
            _buildTabNavigator(_cartNavKey, const CartPage()),
            _buildTabNavigator(_profileNavKey, const ProfilePage()),
          ],
        ),
        bottomNavigationBar: Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, langProvider.translate('nav_home'), selectedIndex, navProvider),
              _buildNavItem(1, Icons.favorite_rounded, Icons.favorite_outline_rounded, langProvider.translate('nav_favorites'), selectedIndex, navProvider),
              _buildNavItem(2, Icons.assignment_rounded, Icons.assignment_outlined, langProvider.translate('nav_orders'), selectedIndex, navProvider),
              _buildNavItem(3, Icons.shopping_basket_rounded, Icons.shopping_basket_outlined, langProvider.translate('nav_cart'), selectedIndex, navProvider),
              _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, langProvider.translate('nav_profile'), selectedIndex, navProvider),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, int selectedIndex, NavigationProvider navProvider) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0 && selectedIndex == 0) {
          _homeNavKey.currentState?.popUntil((route) => route.isFirst);
          navProvider.triggerHomeReset();
        } else {
          navProvider.setIndex(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
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
                  return Badge(
                    label: Text(
                      itemCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    isLabelVisible: itemCount > 0,
                    backgroundColor: Colors.red,
                    offset: const Offset(8, -8),
                    child: AddToCartIcon(
                      key: cartKey,
                      icon: Icon(
                        isSelected ? activeIcon : inactiveIcon,
                        color: isSelected ? AppColors.primary : Colors.black, // <-- Koyu siyah dÄ±ÅŸ Ã§izgi
                        size: 26,
                      ),
                      badgeOptions: const BadgeOptions(active: false),
                    ),
                  );
                },
              )
            else
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? AppColors.primary : Colors.black, // <-- Koyu siyah dÄ±ÅŸ Ã§izgi
                size: 26,
              ),
            if (isSelected)
              const SizedBox(height: 4),
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  GlobalKey<NavigatorState> _getSelectedNavigatorKey(int index) {
    switch (index) {
      case 0: return _homeNavKey;
      case 1: return _favNavKey;
      case 2: return _ordersNavKey;
      case 3: return _cartNavKey;
      case 4: return _profileNavKey;
      default: return _homeNavKey;
    }
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

