import 'package:equatable/equatable.dart';
import 'package:field_time/features/coupons/data/models/coupon_model.dart';

abstract class CouponManagementState extends Equatable {
  const CouponManagementState();

  @override
  List<Object?> get props => [];
}

class CouponManagementInitial extends CouponManagementState {}

class CouponManagementLoading extends CouponManagementState {}

class CouponManagementLoaded extends CouponManagementState {
  final List<CouponModel> coupons;
  final String? successMessage;

  const CouponManagementLoaded({
    required this.coupons,
    this.successMessage,
  });

  CouponManagementLoaded copyWith({
    List<CouponModel>? coupons,
    String? successMessage,
  }) {
    return CouponManagementLoaded(
      coupons: coupons ?? this.coupons,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [coupons, successMessage];
}

class CouponManagementError extends CouponManagementState {
  final String message;

  const CouponManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

class CouponCreatedSuccess extends CouponManagementState {
  final CouponModel coupon;

  const CouponCreatedSuccess(this.coupon);

  @override
  List<Object?> get props => [coupon];
}
