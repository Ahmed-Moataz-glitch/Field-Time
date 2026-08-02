import 'package:equatable/equatable.dart';

class CouponModel extends Equatable {
  final String id;
  final String code;
  final String discountType; // 'fixed' or 'percentage'
  final double discountValue;
  final double minBookingAmount;
  final double? maxDiscountAmount;
  final DateTime? expiresAt;
  final bool isActive;
  final int? usageLimit;
  final int usedCount;

  const CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minBookingAmount = 0.0,
    this.maxDiscountAmount,
    this.expiresAt,
    this.isActive = true,
    this.usageLimit,
    this.usedCount = 0,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get isLimitReached => usageLimit != null && usedCount >= usageLimit!;

  bool isUsable(double bookingAmount) {
    if (!isActive) return false;
    if (isExpired) return false;
    if (isLimitReached) return false;
    if (bookingAmount < minBookingAmount) return false;
    return true;
  }

  double calculateDiscount(double bookingAmount) {
    if (!isUsable(bookingAmount)) return 0.0;

    double calculated = 0.0;
    if (discountType == 'free') {
      calculated = bookingAmount;
    } else if (discountType == 'percentage') {
      calculated = (bookingAmount * discountValue) / 100.0;
      if (maxDiscountAmount != null && calculated > maxDiscountAmount!) {
        calculated = maxDiscountAmount!;
      }
    } else {
      calculated = discountValue;
    }

    return calculated.clamp(0.0, bookingAmount);
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as String? ?? '',
      code: (json['code'] as String? ?? '').toUpperCase(),
      discountType: json['discount_type'] as String? ?? 'fixed',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      minBookingAmount: (json['min_booking_amount'] as num?)?.toDouble() ?? 0.0,
      maxDiscountAmount: (json['max_discount_amount'] as num?)?.toDouble(),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      isActive: json['is_active'] as bool? ?? true,
      usageLimit: json['usage_limit'] as int?,
      usedCount: json['used_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_booking_amount': minBookingAmount,
      'max_discount_amount': maxDiscountAmount,
      'expires_at': expiresAt?.toIso8601String(),
      'is_active': isActive,
      'usage_limit': usageLimit,
      'used_count': usedCount,
    };
  }

  @override
  List<Object?> get props => [
        id,
        code,
        discountType,
        discountValue,
        minBookingAmount,
        maxDiscountAmount,
        expiresAt,
        isActive,
        usageLimit,
        usedCount,
      ];
}
