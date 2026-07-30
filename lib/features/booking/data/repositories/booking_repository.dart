import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/core/errors/failures.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';

class BookingRepository {
  final SupabaseClient _supabase;

  BookingRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  static final List<BookingModel> _mockBookings = [
    const BookingModel(
      id: 'booking-1',
      fieldId: 'field-1',
      fieldName: 'أرينا سبورت (Arena Sport)',
      fieldAddress: 'مدينة نصر - شارع الطيران',
      fieldImage: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
      date: 'الجمعة 24 مايو 2024',
      startTime: '19:00',
      endTime: '20:00',
      price: 350.0,
      status: 'confirmed',
      bookingCode: '#FT-2024-0524-0012',
    ),
    const BookingModel(
      id: 'booking-2',
      fieldId: 'field-2',
      fieldName: 'جول ميكرز (Goal Makers)',
      fieldAddress: 'التجمع الخامس - شارع التسعين',
      fieldImage: 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&q=80&w=800',
      date: 'السبت 25 مايو 2024',
      startTime: '17:00',
      endTime: '18:00',
      price: 300.0,
      status: 'confirmed',
      bookingCode: '#FT-2024-0525-0015',
    ),
  ];

  Future<List<BookingModel>> getBookings() async {
    try {
      final response = await _supabase.from('bookings').select('*');
      if ((response as List).isNotEmpty) {
        return response.map((item) => BookingModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return List.from(_mockBookings);
  }

  Future<bool> checkIsSlotAvailable({
    required String fieldId,
    required String date,
    required String startTime,
  }) async {
    // 1. Check local active mock bookings
    final isLocallyBooked = _mockBookings.any(
      (b) => b.fieldId == fieldId && b.date == date && b.startTime == startTime && b.status != 'cancelled',
    );
    if (isLocallyBooked) return false;

    // 2. Check Supabase DB bookings table
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('field_id', fieldId)
          .eq('booking_date', date)
          .eq('start_time', startTime)
          .neq('status', 'cancelled');

      if ((response as List).isNotEmpty) {
        return false;
      }
    } catch (_) {}

    return true;
  }

  Future<BookingModel> createBooking({
    required String fieldId,
    required String fieldName,
    required String fieldAddress,
    required String fieldImage,
    required String date,
    required String startTime,
    required String endTime,
    required double price,
  }) async {
    // Prevent Duplicate Booking Check
    final isAvailable = await checkIsSlotAvailable(
      fieldId: fieldId,
      date: date,
      startTime: startTime,
    );

    if (!isAvailable) {
      throw const DuplicateBookingFailure('هذا الموعد محجوز بالفعل! يرجى اختيار موعد آخر.');
    }

    final now = DateTime.now();
    final bookingCode = '#FT-${now.year}-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(1000 + now.millisecond % 9000)}';

    final newBooking = BookingModel(
      id: 'booking-${now.millisecondsSinceEpoch}',
      fieldId: fieldId,
      fieldName: fieldName,
      fieldAddress: fieldAddress,
      fieldImage: fieldImage,
      date: date,
      startTime: startTime,
      endTime: endTime,
      price: price,
      status: 'confirmed', // Instant booking confirmed state
      bookingCode: bookingCode,
    );

    try {
      await _supabase.from('bookings').insert(newBooking.toJson());
    } catch (_) {}

    _mockBookings.insert(0, newBooking);
    return newBooking;
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _supabase.from('bookings').update({'status': 'cancelled'}).eq('id', bookingId);
    } catch (_) {}

    final index = _mockBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _mockBookings[index] = _mockBookings[index].copyWith(status: 'cancelled');
    }
  }
}
