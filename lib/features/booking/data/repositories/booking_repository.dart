import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';

class BookingRepository {
  final SupabaseClient _supabase;

  BookingRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  static final List<BookingModel> _mockBookings = [
    const BookingModel(
      id: 'booking-1',
      fieldId: 'field-1',
      fieldName: 'Arena Sport',
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
      fieldName: 'Goal Makers',
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
      final response = await _supabase.from('bookings').select('*, football_fields(*)');
      if ((response as List).isNotEmpty) {
        return response.map((item) => BookingModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return _mockBookings;
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
    final bookingCode = '#FT-${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${(1000 + DateTime.now().millisecond % 9000)}';
    
    final newBooking = BookingModel(
      id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
      fieldId: fieldId,
      fieldName: fieldName,
      fieldAddress: fieldAddress,
      fieldImage: fieldImage,
      date: date,
      startTime: startTime,
      endTime: endTime,
      price: price,
      status: 'confirmed',
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
