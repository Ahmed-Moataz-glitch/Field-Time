import 'package:equatable/equatable.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';
import 'package:field_time/features/coupons/data/models/coupon_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;
  final String activeTab;
  final BookingModel? lastCreatedBooking;

  const BookingLoaded({
    required this.bookings,
    this.activeTab = 'القادمة',
    this.lastCreatedBooking,
  });

  BookingLoaded copyWith({
    List<BookingModel>? bookings,
    String? activeTab,
    BookingModel? lastCreatedBooking,
  }) {
    return BookingLoaded(
      bookings: bookings ?? this.bookings,
      activeTab: activeTab ?? this.activeTab,
      lastCreatedBooking: lastCreatedBooking ?? this.lastCreatedBooking,
    );
  }

  @override
  List<Object?> get props => [bookings, activeTab, lastCreatedBooking];
}

class BookedSlotsLoaded extends BookingState {
  final Set<String> bookedSlots;

  const BookedSlotsLoaded(this.bookedSlots);

  @override
  List<Object?> get props => [bookedSlots];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingDuplicateError extends BookingState {
  final String message;

  const BookingDuplicateError([this.message = 'هذا الموعد محجوز بالفعل! يرجى اختيار موعد آخر.']);

  @override
  List<Object?> get props => [message];
}

class CouponApplying extends BookingState {}

class CouponAppliedState extends BookingState {
  final CouponModel coupon;
  final double discountAmount;
  final double finalPrice;

  const CouponAppliedState({
    required this.coupon,
    required this.discountAmount,
    required this.finalPrice,
  });

  @override
  List<Object?> get props => [coupon, discountAmount, finalPrice];
}

class CouponErrorState extends BookingState {
  final String message;

  const CouponErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
