import 'package:equatable/equatable.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';

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

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
