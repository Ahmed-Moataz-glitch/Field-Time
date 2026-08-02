import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/core/errors/failures.dart';
import 'package:field_time/features/coupons/data/models/coupon_model.dart';
import 'package:field_time/features/coupons/data/repositories/coupon_repository.dart';
import 'package:field_time/features/coupons/presentation/cubit/coupon_management_state.dart';

class CouponManagementCubit extends Cubit<CouponManagementState> {
  final CouponRepository _repository;

  CouponManagementCubit([CouponRepository? repository])
      : _repository = repository ?? CouponRepository(),
        super(CouponManagementInitial());

  Future<void> loadCoupons() async {
    emit(CouponManagementLoading());
    try {
      final coupons = await _repository.getAllCoupons();
      emit(CouponManagementLoaded(coupons: coupons));
    } catch (e) {
      emit(CouponManagementError(e.toString()));
    }
  }

  Future<CouponModel?> createCoupon({
    required String code,
    required String discountType,
    required double discountValue,
    double minBookingAmount = 0.0,
    double? maxDiscountAmount,
    DateTime? expiresAt,
    int? usageLimit,
  }) async {
    try {
      final newCoupon = await _repository.createCoupon(
        code: code,
        discountType: discountType,
        discountValue: discountValue,
        minBookingAmount: minBookingAmount,
        maxDiscountAmount: maxDiscountAmount,
        expiresAt: expiresAt,
        usageLimit: usageLimit,
      );

      emit(CouponCreatedSuccess(newCoupon));
      await loadCoupons();
      return newCoupon;
    } on CouponFailure catch (e) {
      emit(CouponManagementError(e.message));
      return null;
    } catch (e) {
      emit(const CouponManagementError('فشل إنشاء الكوبون. حاول مرة أخرى.'));
      return null;
    }
  }

  Future<void> toggleCouponActive(String couponId, bool isActive) async {
    try {
      await _repository.toggleCouponActive(couponId, isActive);
      await loadCoupons();
    } catch (e) {
      emit(CouponManagementError(e.toString()));
    }
  }
}
