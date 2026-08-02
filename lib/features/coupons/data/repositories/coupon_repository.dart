import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/core/errors/failures.dart';
import 'package:field_time/features/coupons/data/models/coupon_model.dart';

class CouponRepository {
  final SupabaseClient _supabase;

  CouponRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  static final List<CouponModel> _mockCoupons = [
    CouponModel(
      id: 'coupon-1',
      code: 'FIELD20',
      discountType: 'percentage',
      discountValue: 20.0,
      minBookingAmount: 100.0,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      isActive: true,
    ),
    CouponModel(
      id: 'coupon-2',
      code: 'OFFER50',
      discountType: 'fixed',
      discountValue: 50.0,
      minBookingAmount: 200.0,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      isActive: true,
    ),
    CouponModel(
      id: 'coupon-3',
      code: 'WELCOME100',
      discountType: 'fixed',
      discountValue: 100.0,
      minBookingAmount: 300.0,
      expiresAt: DateTime.now().add(const Duration(days: 60)),
      isActive: true,
    ),
    CouponModel(
      id: 'coupon-4',
      code: 'FREE100',
      discountType: 'percentage',
      discountValue: 100.0,
      minBookingAmount: 0.0,
      expiresAt: DateTime.now().add(const Duration(days: 90)),
      isActive: true,
    ),
    CouponModel(
      id: 'coupon-5',
      code: 'FREEFIELD',
      discountType: 'free',
      discountValue: 100.0,
      minBookingAmount: 0.0,
      expiresAt: DateTime.now().add(const Duration(days: 90)),
      isActive: true,
    ),
  ];

  /// Get all coupons from Supabase DB or mock list
  Future<List<CouponModel>> getAllCoupons() async {
    try {
      final response = await _supabase
          .from('coupons')
          .select()
          .order('created_at', ascending: false);

      if ((response as List).isNotEmpty) {
        return response.map((item) => CouponModel.fromJson(item)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Supabase getAllCoupons Warning: $e');
    }
    return List.from(_mockCoupons);
  }

  /// Create a new coupon in Supabase and mock list
  Future<CouponModel> createCoupon({
    required String code,
    required String discountType,
    required double discountValue,
    double minBookingAmount = 0.0,
    double? maxDiscountAmount,
    DateTime? expiresAt,
    int? usageLimit,
  }) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      throw const CouponFailure('يرجى إدخال كود الخصم');
    }

    // Check duplicate in local mock list
    if (_mockCoupons.any((c) => c.code == cleanCode)) {
      throw const CouponFailure('كود الخصم هذا موجود بالفعل');
    }

    final newCoupon = CouponModel(
      id: 'coupon-${DateTime.now().millisecondsSinceEpoch}',
      code: cleanCode,
      discountType: discountType,
      discountValue: discountValue,
      minBookingAmount: minBookingAmount,
      maxDiscountAmount: maxDiscountAmount,
      expiresAt: expiresAt,
      isActive: true,
      usageLimit: usageLimit,
      usedCount: 0,
    );

    try {
      await _supabase.from('coupons').insert(newCoupon.toJson());
    } catch (e) {
      if (kDebugMode) print('Supabase createCoupon Warning: $e');
    }

    _mockCoupons.insert(0, newCoupon);
    return newCoupon;
  }

  /// Toggle active/inactive status of a coupon
  Future<void> toggleCouponActive(String couponId, bool isActive) async {
    try {
      await _supabase.from('coupons').update({'is_active': isActive}).eq('id', couponId);
    } catch (e) {
      if (kDebugMode) print('Supabase toggleCouponActive Warning: $e');
    }

    final index = _mockCoupons.indexWhere((c) => c.id == couponId);
    if (index != -1) {
      final c = _mockCoupons[index];
      _mockCoupons[index] = CouponModel(
        id: c.id,
        code: c.code,
        discountType: c.discountType,
        discountValue: c.discountValue,
        minBookingAmount: c.minBookingAmount,
        maxDiscountAmount: c.maxDiscountAmount,
        expiresAt: c.expiresAt,
        isActive: isActive,
        usageLimit: c.usageLimit,
        usedCount: c.usedCount,
      );
    }
  }

  /// Validate coupon by code and booking amount against Supabase DB or mock fallback
  Future<CouponModel> validateCoupon({
    required String code,
    required double bookingAmount,
  }) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      throw const CouponFailure('يرجى إدخال كود الخصم');
    }

    CouponModel? coupon;

    try {
      final response = await _supabase
          .from('coupons')
          .select()
          .eq('code', cleanCode)
          .maybeSingle();

      if (response != null) {
        coupon = CouponModel.fromJson(response);
      }
    } catch (e) {
      if (kDebugMode) print('Supabase Coupon Fetch Warning: $e');
    }

    // Fallback to local mock coupons if DB not available or offline
    coupon ??= _mockCoupons.firstWhere(
      (c) => c.code == cleanCode,
      orElse: () => throw const CouponFailure('كوبون الخصم غير صالح أو غير موجود'),
    );

    if (!coupon.isActive) {
      throw const CouponFailure('كوبون الخصم غير فعال حالياً');
    }

    if (coupon.isExpired) {
      throw const CouponFailure('كوبون الخصم منتهي الصلاحية');
    }

    if (coupon.isLimitReached) {
      throw const CouponFailure('تم استخدام هذا الكوبون بالكامل');
    }

    if (bookingAmount < coupon.minBookingAmount) {
      throw CouponFailure(
        'الحد الأدنى لاستخدام الكوبون هو ${coupon.minBookingAmount.toInt()} جنيه',
      );
    }

    return coupon;
  }

  /// Increment usage count of used coupon in Supabase
  Future<void> incrementCouponUsage(String couponId) async {
    try {
      await _supabase.rpc('increment_coupon_usage', params: {'coupon_id': couponId});
    } catch (_) {
      try {
        final coupon = await _supabase.from('coupons').select('used_count').eq('id', couponId).maybeSingle();
        if (coupon != null) {
          final count = (coupon['used_count'] as int? ?? 0) + 1;
          await _supabase.from('coupons').update({'used_count': count}).eq('id', couponId);
        }
      } catch (_) {}
    }
  }
}
