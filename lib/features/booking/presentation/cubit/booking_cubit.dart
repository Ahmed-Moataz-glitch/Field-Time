import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/core/errors/failures.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';
import 'package:field_time/features/booking/data/repositories/booking_repository.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_state.dart';
import 'package:field_time/features/coupons/data/models/coupon_model.dart';
import 'package:field_time/features/coupons/data/repositories/coupon_repository.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _repository;
  final CouponRepository _couponRepository;

  BookingCubit({
    BookingRepository? repository,
    CouponRepository? couponRepository,
  })  : _repository = repository ?? BookingRepository(),
        _couponRepository = couponRepository ?? CouponRepository(),
        super(BookingInitial());

  Future<void> loadBookings() async {
    emit(BookingLoading());
    try {
      final bookings = await _repository.getBookings();
      emit(BookingLoaded(bookings: bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  void changeTab(String tab) {
    if (state is BookingLoaded) {
      final currentState = state as BookingLoaded;
      emit(currentState.copyWith(activeTab: tab));
    }
  }

  Future<Set<String>> loadBookedSlots({
    required String fieldId,
    required String date,
  }) async {
    try {
      final bookedSlots = await _repository.getBookedSlots(
        fieldId: fieldId,
        date: date,
      );
      emit(BookedSlotsLoaded(bookedSlots));
      return bookedSlots;
    } catch (_) {
      return {};
    }
  }

  Future<bool> isSlotAvailable({
    required String fieldId,
    required String date,
    required String startTime,
  }) async {
    return await _repository.checkIsSlotAvailable(
      fieldId: fieldId,
      date: date,
      startTime: startTime,
    );
  }

  /// Apply coupon using backend/repository validation
  Future<CouponModel?> applyCoupon({
    required String code,
    required double currentPrice,
  }) async {
    emit(CouponApplying());
    try {
      final coupon = await _couponRepository.validateCoupon(
        code: code,
        bookingAmount: currentPrice,
      );
      final discount = coupon.calculateDiscount(currentPrice);
      final finalPrice = (currentPrice - discount).clamp(0.0, currentPrice);

      emit(CouponAppliedState(
        coupon: coupon,
        discountAmount: discount,
        finalPrice: finalPrice,
      ));
      return coupon;
    } on CouponFailure catch (e) {
      emit(CouponErrorState(e.message));
      return null;
    } catch (e) {
      emit(const CouponErrorState('فشل تطبيق كود الخصم'));
      return null;
    }
  }

  Future<BookingModel?> createBooking({
    required String fieldId,
    required String fieldName,
    required String fieldAddress,
    required String fieldImage,
    required String date,
    required String timeSlot,
    required double price,
    double? originalPrice,
    double discountAmount = 0.0,
    String? couponCode,
    String? couponId,
  }) async {
    try {
      final times = timeSlot.split(' - ');
      final startTime = times.isNotEmpty ? times[0] : '19:00';
      final endTime = times.length > 1 ? times[1] : '20:00';

      final booking = await _repository.createBooking(
        fieldId: fieldId,
        fieldName: fieldName,
        fieldAddress: fieldAddress,
        fieldImage: fieldImage,
        date: date,
        startTime: startTime,
        endTime: endTime,
        price: price,
        originalPrice: originalPrice,
        discountAmount: discountAmount,
        couponCode: couponCode,
        couponId: couponId,
      );

      await loadBookings();
      if (state is BookingLoaded) {
        emit((state as BookingLoaded).copyWith(lastCreatedBooking: booking));
      }
      return booking;
    } on DuplicateBookingFailure catch (e) {
      emit(BookingDuplicateError(e.message));
      return null;
    } catch (e) {
      emit(BookingError(e.toString()));
      return null;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _repository.cancelBooking(bookingId);
      await loadBookings();
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
