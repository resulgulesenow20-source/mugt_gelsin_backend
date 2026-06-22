import 'package:flutter/material.dart';
import '../models/coupon_model.dart';

class CouponProvider with ChangeNotifier {
  List<Coupon> _coupons = [];
  bool _isLoading = false;

  List<Coupon> get coupons => _coupons;
  bool get isLoading => _isLoading;

  Future<void> fetchCoupons() async {
    _isLoading = true;
    notifyListeners();

    // Mocking a delay and data
    await Future.delayed(const Duration(seconds: 1));

    _coupons = [
      Coupon(
        id: '1',
        code: 'YENI20',
        title: 'Hos Geldin Indirimi',
        description: 'Ilk siparisine özel %20 indirim!',
        discountAmount: 20,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        type: 'percentage',
      ),
      Coupon(
        id: '2',
        code: 'mugut50',
        title: 'Hafta Sonu Firsati',
        description: '50 TL ve üzeri siparislerde 15 TL indirim.',
        discountAmount: 15,
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        type: 'amount',
      ),
      Coupon(
        id: '3',
        code: 'ESKI10',
        title: 'Geçmis Kupon',
        description: 'Süresi dolmus bir kupon örnegi.',
        discountAmount: 10,
        expiryDate: DateTime.now().subtract(const Duration(days: 5)),
        type: 'amount',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void markAsUsed(String couponId) {
    final index = _coupons.indexWhere((c) => c.id == couponId);
    if (index != -1) {
      final coupon = _coupons[index];
      _coupons[index] = Coupon(
        id: coupon.id,
        code: coupon.code,
        title: coupon.title,
        description: coupon.description,
        discountAmount: coupon.discountAmount,
        expiryDate: coupon.expiryDate,
        isUsed: true,
        type: coupon.type,
      );
      notifyListeners();
    }
  }
}

