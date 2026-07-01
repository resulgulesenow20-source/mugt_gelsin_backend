import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mugut_gelsin/pages/orders/add_review_page.dart';
import 'package:mugut_gelsin/pages/orders/order_tracking_page.dart';
import 'package:mugut_gelsin/pages/profile/live_support_page.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/cart_provider.dart';
import 'package:mugut_gelsin/models/restaurant_model.dart';
import 'package:mugut_gelsin/models/order_model.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _searchQuery = "";
  String _selectedFilter = "all"; // "all", "30days", "active", "delivered", "cancelled"
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getLocalText(String selectedLang, String key, {Map<String, String>? args}) {
    final Map<String, Map<String, String>> localTranslations = {
      'TR': {
        'no_orders': 'Henüz siparişiniz bulunmamaktadır',
        'no_active_orders': 'Aktif siparişiniz bulunmuyor',
        'no_past_orders': 'Geçmiş siparişiniz bulunmuyor',
        'no_filter_results': 'Arama kriterlerinize uygun sipariş bulunamadı.',
        'login_required': 'Siparişlerinizi görmek için lütfen giriş yapın.',
        'reorder_success': '{shopName} siparişiniz sepete tekrar eklendi!',
        'total': 'Toplam',
        'order_status_pending': 'Onay Bekliyor',
        'order_status_preparing': 'Hazırlanıyor',
        'order_status_on_the_way': 'Yolda',
        'order_status_delivered': 'Teslim Edildi',
        'order_status_cancelled': 'İptal Edildi',
        'search_hint_orders': 'Restoran adına göre ara...',
        'filter_all': 'Tümü',
        'filter_30days': 'Son 30 Gün',
        'filter_active': 'Aktifler',
        'filter_delivered': 'Teslim Edilenler',
        'filter_cancelled': 'İptaller',
        'order_cancelled_banner': 'Bu sipariş iptal edilmiştir.',
        'order_status_title': 'SİPARİŞ DURUMU',
        'received': 'Alındı',
        'preparing': 'Hazırlanıyor',
        'on_way': 'Yolda',
        'delivered': 'Eltildi',
        'address_title': 'Teslimat Adresi',
        'note_title': 'Sipariş Notu',
        'payment_title': 'Ödeme Bilgileri',
        'payment_method': 'Ödeme Yöntemi',
        'subtotal': 'Ara Toplam',
        'discount': 'İndirim',
        'coupon': 'Kupon Kodu',
        'show_details': 'Detayları Göster',
        'hide_details': 'Detayları Gizle',
        'items_count': '{count} Ürün',
        'support': 'Destek Al',
        'courier': 'Kurye',
      },
      'TM': {
        'no_orders': 'Entek sargydyňyz ýok',
        'no_active_orders': 'Aktif sargydyňyz ýok',
        'no_past_orders': 'Geçmiş sargydyňyz ýok',
        'no_filter_results': 'Gözleg kriteriýalaryna laýyk sargyt tapylmady.',
        'login_required': 'Sargytlaryňyzy görmek üçin ulgama giriň.',
        'reorder_success': '{shopName} sargydyňyz sebede gaýtadan goşuldy!',
        'total': 'Jemi',
        'order_status_pending': 'Tassyklama Garaşylýar',
        'order_status_preparing': 'Taýýarlanýar',
        'order_status_on_the_way': 'Ýolda',
        'order_status_delivered': 'Eltildi',
        'order_status_cancelled': 'Bes edildi',
        'search_hint_orders': 'Restoran adyna görä gözle...',
        'filter_all': 'Ählisi',
        'filter_30days': 'Soňky 30 gün',
        'filter_active': 'Aktiwler',
        'filter_delivered': 'Eltilenler',
        'filter_cancelled': 'Bes edilenler',
        'order_cancelled_banner': 'Bu sargyt bes edildi.',
        'order_status_title': 'SARGYT ÝAGDAÝY',
        'received': 'Alyndy',
        'preparing': 'Taýýarlanýar',
        'on_way': 'Ýolda',
        'delivered': 'Eltildi',
        'address_title': 'Eltip bermeli adres',
        'note_title': 'Sargyt belgisi',
        'payment_title': 'Töleg maglumatlary',
        'payment_method': 'Töleg usuly',
        'subtotal': 'Baha jemi',
        'discount': 'Arzanladyş',
        'coupon': 'Kupon kody',
        'show_details': 'Jikme-jikleri görkez',
        'hide_details': 'Jikme-jikleri gizle',
        'items_count': '{count} Önüm',
        'support': 'Goldaw al',
        'courier': 'Kuryer',
      },
      'RU': {
        'no_orders': 'У вас еще нет заказов',
        'no_active_orders': 'Нет активных заказов',
        'no_past_orders': 'Нет прошедших заказов',
        'no_filter_results': 'Заказы, соответствующие критериям поиска, не найдены.',
        'login_required': 'Войдите, чтобы просмотреть свои заказы.',
        'reorder_success': 'Ваш заказ из {shopName} снова добавлен в корзину!',
        'total': 'Итого',
        'order_status_pending': 'Ожидает подтверждения',
        'order_status_preparing': 'Готовится',
        'order_status_on_the_way': 'В пути',
        'order_status_delivered': 'Доставлено',
        'order_status_cancelled': 'Отменено',
        'search_hint_orders': 'Поиск по названию ресторана...',
        'filter_all': 'Все',
        'filter_30days': 'За 30 дней',
        'filter_active': 'Активные',
        'filter_delivered': 'Доставлено',
        'filter_cancelled': 'Отменено',
        'order_cancelled_banner': 'Этот заказ был отменен.',
        'order_status_title': 'СТАТУС ЗАКАЗА',
        'received': 'Принят',
        'preparing': 'Готовится',
        'on_way': 'В пути',
        'delivered': 'Доставлено',
        'address_title': 'Адрес доставки',
        'note_title': 'Примечание к заказу',
        'payment_title': 'Информация об оплате',
        'payment_method': 'Способ оплаты',
        'subtotal': 'Подытог',
        'discount': 'Скидка',
        'coupon': 'Промокод',
        'show_details': 'Показать детали',
        'hide_details': 'Скрыть детали',
        'items_count': 'Товаров: {count}',
        'support': 'Поддержка',
        'courier': 'Курьер',
      }
    };

    String text = localTranslations[selectedLang]?[key] ?? localTranslations['TR']?[key] ?? key;
    if (args != null) {
      args.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }

  void _reorderItems(BuildContext context, OrderModel order, LanguageProvider langProvider) {
    final cart = context.read<CartProvider>();
    final List<OrderItem> items = order.items;
    final String shopId = order.shopId;
    final String shopName = order.shopName;

    if (items.isEmpty) return;
    
    for (var item in items) {
      final String name = item.name;
      final double price = item.price;
      final int quantity = item.quantity;
      final String imageUrl = item.imageUrl ?? '';

      final food = Food(
        id: name.hashCode.toString(),
        name: name,
        price: price,
        imageUrl: imageUrl,
        description: '',
      );

      for (int i = 0; i < quantity; i++) {
        cart.addToCart(
          food,
          restaurantId: shopId,
          restaurantName: shopName,
        );
      }
    }

    final successMsg = _getLocalText(langProvider.selectedLang, 'reorder_success', args: {'shopName': shopName});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMsg),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildFilterChip(String value, String labelKey, String langCode) {
    final isSelected = _selectedFilter == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          _getLocalText(langCode, labelKey),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = value;
            });
          }
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceSubtle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, LanguageProvider langProvider, String langCode, String messageKey) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: AppColors.primary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getLocalText(langCode, messageKey),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              langProvider.translate('empty_cart_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  context.read<NavigationProvider>().setIndex(0);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  langProvider.translate('start_shopping'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final langProvider = context.watch<LanguageProvider>();
    final langCode = langProvider.selectedLang;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          langProvider.translate('orders'),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.textTitle,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(106),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: [
                // Sleek Search Bar
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: _getLocalText(langCode, 'search_hint_orders'),
                      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = "";
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Filter Chips List
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'filter_all', langCode),
                      _buildFilterChip('30days', 'filter_30days', langCode),
                      _buildFilterChip('active', 'filter_active', langCode),
                      _buildFilterChip('delivered', 'filter_delivered', langCode),
                      _buildFilterChip('cancelled', 'filter_cancelled', langCode),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: currentUser == null
          ? Center(
              child: Text(
                _getLocalText(langCode, 'login_required'),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Emirler')
                  .where('customerUid', isEqualTo: currentUser?.uid ?? 'guest')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Hata oluştu: ${snapshot.error}"),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(context, langProvider, langCode, 'no_orders');
                }

                // In-memory sorting and mapping
                final docs = snapshot.data!.docs.toList();
                var allOrders = docs.map((doc) {
                  return OrderModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                // Sort by date descending
                allOrders.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                // Apply search query filter (restaurant name)
                if (_searchQuery.isNotEmpty) {
                  allOrders = allOrders.where((order) =>
                    order.shopName.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                // Apply selected status filter
                if (_selectedFilter == '30days') {
                  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
                  allOrders = allOrders.where((order) => order.timestamp.isAfter(thirtyDaysAgo)).toList();
                } else if (_selectedFilter == 'active') {
                  allOrders = allOrders.where((order) =>
                    order.status == OrderStatus.pending ||
                    order.status == OrderStatus.preparing ||
                    order.status == OrderStatus.onWay
                  ).toList();
                } else if (_selectedFilter == 'delivered') {
                  allOrders = allOrders.where((order) => order.status == OrderStatus.delivered).toList();
                } else if (_selectedFilter == 'cancelled') {
                  allOrders = allOrders.where((order) => order.status == OrderStatus.cancelled).toList();
                }

                if (allOrders.isEmpty) {
                  return _buildEmptyState(context, langProvider, langCode, 'no_filter_results');
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: allOrders.length,
                  itemBuilder: (context, index) {
                    return _OrderCardWidget(
                      order: allOrders[index],
                      langProvider: langProvider,
                      langCode: langCode,
                      onReorder: _reorderItems,
                      getLocalText: _getLocalText,
                    );
                  },
                );
              },
            ),
    );
  }
}

// ✅ PREMIUM EXPANDABLE ORDER CARD
class _OrderCardWidget extends StatefulWidget {
  final OrderModel order;
  final LanguageProvider langProvider;
  final String langCode;
  final Function(BuildContext, OrderModel, LanguageProvider) onReorder;
  final String Function(String, String, {Map<String, String>? args}) getLocalText;

  const _OrderCardWidget({
    required this.order,
    required this.langProvider,
    required this.langCode,
    required this.onReorder,
    required this.getLocalText,
  });

  @override
  State<_OrderCardWidget> createState() => _OrderCardWidgetState();
}

class _OrderCardWidgetState extends State<_OrderCardWidget> {
  bool _isExpanded = false;

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.preparing:
        return AppColors.primary;
      case OrderStatus.onWay:
        return Colors.blue;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  Widget _buildStatusBadge(OrderStatus status, String langCode) {
    final color = _getStatusColor(status);
    IconData icon;
    String labelKey;

    switch (status) {
      case OrderStatus.pending:
        icon = Icons.access_time_rounded;
        labelKey = 'order_status_pending';
        break;
      case OrderStatus.preparing:
        icon = Icons.restaurant_rounded;
        labelKey = 'order_status_preparing';
        break;
      case OrderStatus.onWay:
        icon = Icons.delivery_dining_rounded;
        labelKey = 'order_status_on_the_way';
        break;
      case OrderStatus.delivered:
        icon = Icons.check_circle_rounded;
        labelKey = 'order_status_delivered';
        break;
      case OrderStatus.cancelled:
        icon = Icons.cancel_rounded;
        labelKey = 'order_status_cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.18), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            widget.getLocalText(langCode, labelKey).toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String? method) {
    switch (method?.toLowerCase()) {
      case 'kapida_nakit':
        return Icons.attach_money_rounded;
      case 'kapida_kart':
        return Icons.credit_card_rounded;
      case 'online_kart':
        return Icons.payment_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Widget _buildTimeline(OrderStatus status) {
    if (status == OrderStatus.cancelled) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.getLocalText(widget.langCode, 'order_cancelled_banner'),
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    int activeIndex = 0;
    switch (status) {
      case OrderStatus.pending:
        activeIndex = 0;
        break;
      case OrderStatus.preparing:
        activeIndex = 1;
        break;
      case OrderStatus.onWay:
        activeIndex = 2;
        break;
      case OrderStatus.delivered:
        activeIndex = 3;
        break;
      case OrderStatus.cancelled:
        activeIndex = 0;
        break;
    }

    final steps = [
      {'title': 'received', 'icon': Icons.assignment_turned_in_rounded},
      {'title': 'preparing', 'icon': Icons.restaurant_rounded},
      {'title': 'on_way', 'icon': Icons.delivery_dining_rounded},
      {'title': 'delivered', 'icon': Icons.check_circle_rounded},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.getLocalText(widget.langCode, 'order_status_title'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isCompleted = index < activeIndex;
              final isActive = index == activeIndex;

              Color color;
              if (isCompleted) {
                color = AppColors.success;
              } else if (isActive) {
                color = AppColors.primary;
              } else {
                color = Colors.grey[300]!;
              }

              Color iconColor = (isActive || isCompleted) ? Colors.white : Colors.grey[600]!;

              return Expanded(
                child: Row(
                  children: [
                    // Circle indicator
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_rounded : (step['icon'] as IconData),
                            color: iconColor,
                            size: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.getLocalText(widget.langCode, step['title'] as String),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: (isActive || isCompleted) ? FontWeight.bold : FontWeight.normal,
                            color: isActive
                                ? AppColors.primary
                                : ((isCompleted) ? AppColors.success : AppColors.textTertiary),
                          ),
                        ),
                      ],
                    ),

                    // Connecting bar
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 15, left: 4, right: 4),
                          decoration: BoxDecoration(
                            color: (index < activeIndex) ? AppColors.success : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final langProvider = widget.langProvider;
    final langCode = widget.langCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Core Header: Restaurant, Date, Status
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            order.shopName.isNotEmpty ? order.shopName[0].toUpperCase() : 'R',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.shopName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.textTitle,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _formatDate(order.timestamp),
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(order.status, langCode),
                    ],
                  ),

                  // Collapsed vs Expanded Content with AnimatedCrossFade
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Divider(height: 1, thickness: 0.5, color: Colors.black12),
                        const SizedBox(height: 12),
                        
                        // Summary info row
                        Row(
                          children: [
                            if (order.items.isNotEmpty) ...[
                              SizedBox(
                                height: 36,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: order.items.length > 3 ? 3 : order.items.length,
                                  itemBuilder: (context, idx) {
                                    final item = order.items[idx];
                                    return Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.black.withOpacity(0.05),
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: CachedNetworkImage(
                                          imageUrl: item.imageUrl ?? '',
                                          width: 34,
                                          height: 34,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) => Container(
                                            width: 34,
                                            height: 34,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.fastfood, color: Colors.grey, size: 14),
                                          ),
                                          placeholder: (context, url) => Container(
                                            width: 34,
                                            height: 34,
                                            color: Colors.grey[100],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (order.items.length > 3)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "+${order.items.length - 3}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                order.items.map((e) => "${e.quantity}x ${e.name}").join(', '),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${order.totalPrice.toStringAsFixed(2)} TMT",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textTitle,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.getLocalText(langCode, 'show_details'),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Progress Step Timeline
                        _buildTimeline(order.status),
                        
                        // 2. Full Items Summary List
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...order.items.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: item.imageUrl ?? '',
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url, error) => Container(
                                                  width: 40,
                                                  height: 40,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.fastfood, color: Colors.grey, size: 16),
                                                ),
                                                placeholder: (context, url) => Container(
                                                  width: 40,
                                                  height: 40,
                                                  color: Colors.grey[100],
                                                  child: const Center(
                                                    child: SizedBox(
                                                      width: 12,
                                                      height: 12,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 1.5,
                                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                "${item.quantity}x",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              "${item.price.toStringAsFixed(1)} TMT",
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (item.note != null && item.note!.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 90),
                                            child: Text(
                                              "\"${item.note}\"",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontStyle: FontStyle.italic,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  )),
                              
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1, thickness: 0.5, color: Colors.black12),
                              ),
                              
                              // Receipt cost calculation details
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.getLocalText(langCode, 'subtotal'),
                                    style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                  ),
                                  Text(
                                    "${(order.originalPrice ?? order.totalPrice).toStringAsFixed(2)} TMT",
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              if (order.discountAmount != null && order.discountAmount! > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          widget.getLocalText(langCode, 'discount'),
                                          style: const TextStyle(fontSize: 12, color: Colors.green),
                                        ),
                                        if (order.couponCode != null)
                                          Text(
                                            " (${order.couponCode})",
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      "-${order.discountAmount!.toStringAsFixed(2)} TMT",
                                      style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    langProvider.translate('order_summary'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    "${order.totalPrice.toStringAsFixed(2)} TMT",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textTitle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        // 3. Delivery Details (Address + Notes)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black.withOpacity(0.04), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Address Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.getLocalText(langCode, 'address_title'),
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          order.deliveryAddress,
                                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              if (order.note != null && order.note!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                const Divider(height: 1, thickness: 0.5, color: Colors.black12),
                                const SizedBox(height: 8),
                                // Note Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.sticky_note_2_rounded, color: AppColors.warning, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.getLocalText(langCode, 'note_title'),
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            order.note!,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 10),
                              const Divider(height: 1, thickness: 0.5, color: Colors.black12),
                              const SizedBox(height: 8),
                              // Payment Method details
                              Row(
                                children: [
                                  Icon(_getPaymentIcon(order.paymentMethod), color: AppColors.textSecondary, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.getLocalText(langCode, 'payment_method'),
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          order.payment ?? '',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 4. Courier Banner (if exists)
                        if (order.courierName != null && order.courierName!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.withOpacity(0.12)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${widget.getLocalText(langCode, 'courier')}: ",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                                ),
                                Text(
                                  order.courierName!,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // 5. Actions row
                        Row(
                          children: [
                            // Support Chat Button
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LiveSupportPage()),
                                );
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                              label: Text(widget.getLocalText(langCode, 'support')),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: BorderSide(color: Colors.grey.withOpacity(0.4)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Reorder, Rate, Track buttons
                            if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) ...[
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () => widget.onReorder(context, order, langProvider),
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: Text(langProvider.translate('reorder')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: OutlinedButton(
                                  onPressed: order.isRated
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddReviewPage(
                                                orderId: order.id,
                                                restaurantId: order.shopId,
                                                restaurantName: order.shopName,
                                              ),
                                            ),
                                          );
                                        },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: BorderSide(
                                      color: order.isRated ? Colors.black12 : AppColors.primary,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    order.isRated
                                        ? langProvider.translate('rated')
                                        : langProvider.translate('rate'),
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ] else ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderTrackingPage(
                                          orderId: order.id,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.location_searching_rounded, size: 16),
                                  label: Text(langProvider.translate('live_track')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.getLocalText(langCode, 'hide_details'),
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_up_rounded, color: AppColors.textTertiary, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
