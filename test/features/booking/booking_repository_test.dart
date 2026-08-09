import 'package:flutter_test/flutter_test.dart';
import 'package:field_time/features/booking/data/repositories/booking_repository.dart';
import 'package:field_time/core/errors/failures.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:field_time/core/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SupabaseService.init();
  });

  late BookingRepository repository;

  setUp(() {
    repository = BookingRepository();
  });

  group('BookingRepository Unit Tests', () {
    test('getBookings returns list of user bookings', () async {
      final bookings = await repository.getBookings();
      expect(bookings, isNotEmpty);
      expect(bookings.first.fieldName, contains('أرينا سبورت'));
    });

    test('checkIsSlotAvailable returns false for booked slot', () async {
      final isAvailable = await repository.checkIsSlotAvailable(
        fieldId: 'field-1',
        date: '2026-08-03',
        startTime: '19:00',
      );
      expect(isAvailable, isFalse);
    });

    test('checkIsSlotAvailable returns true for unbooked slot', () async {
      final isAvailable = await repository.checkIsSlotAvailable(
        fieldId: 'field-1',
        date: '2026-08-03',
        startTime: '22:00',
      );
      expect(isAvailable, isTrue);
    });

    test('createBooking successfully adds a new booking', () async {
      final newBooking = await repository.createBooking(
        fieldId: 'field-1',
        fieldName: 'أرينا سبورت',
        fieldAddress: 'مدينة نصر',
        fieldImage: 'https://images.unsplash.com/photo-1574629810360',
        date: '2026-08-10',
        startTime: '21:00',
        endTime: '22:00',
        price: 350.0,
      );

      expect(newBooking.status, equals('confirmed'));
      expect(newBooking.bookingCode, startsWith('#FT-'));

      final allBookings = await repository.getBookings();
      expect(allBookings.any((b) => b.id == newBooking.id), isTrue);
    });

    test('createBooking throws DuplicateBookingFailure for taken slot', () async {
      expect(
        () async => await repository.createBooking(
          fieldId: 'field-1',
          fieldName: 'أرينا سبورت',
          fieldAddress: 'مدينة نصر',
          fieldImage: 'https://images.unsplash.com/photo-1574629810360',
          date: '2026-08-03',
          startTime: '19:00',
          endTime: '20:00',
          price: 350.0,
        ),
        throwsA(isA<DuplicateBookingFailure>()),
      );
    });

    test('cancelBooking updates status to cancelled', () async {
      await repository.cancelBooking('booking-1');
      final bookings = await repository.getBookings();
      final cancelled = bookings.firstWhere((b) => b.id == 'booking-1');
      expect(cancelled.status, equals('cancelled'));
    });
  });
}
