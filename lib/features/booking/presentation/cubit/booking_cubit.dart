import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/core/errors/failures.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';
import 'package:field_time/features/booking/data/repositories/booking_repository.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _repository;

  BookingCubit(this._repository) : super(BookingInitial());

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

  Future<BookingModel?> createBooking({
    required String fieldId,
    required String fieldName,
    required String fieldAddress,
    required String fieldImage,
    required String date,
    required String timeSlot,
    required double price,
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
