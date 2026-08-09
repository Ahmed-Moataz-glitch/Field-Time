import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/core/errors/failures.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';
import 'package:field_time/features/coupons/data/repositories/coupon_repository.dart';
import 'package:field_time/features/notifications/data/models/notification_model.dart';
import 'package:field_time/features/notifications/data/repositories/notification_repository.dart';

class BookingRepository {
  final SupabaseClient? _customSupabase;
  final CouponRepository _couponRepository;

  BookingRepository({SupabaseClient? supabase, CouponRepository? couponRepository})
      : _customSupabase = supabase,
        _couponRepository = couponRepository ?? CouponRepository();

  SupabaseClient get _supabase => _customSupabase ?? Supabase.instance.client;

  static final List<BookingModel> _mockBookings = [
    const BookingModel(
      id: 'booking-1',
      fieldId: 'field-1',
      userId: 'u1',
      fieldName: 'أرينا سبورت (Arena Sport)',
      fieldAddress: 'مدينة نصر - شارع الطيران',
      fieldImage: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
      date: '2026-08-03',
      startTime: '19:00',
      endTime: '20:00',
      price: 350.0,
      originalPrice: 350.0,
      discountAmount: 0.0,
      status: 'confirmed',
      bookingCode: '#FT-2026-0803-0012',
    ),
    const BookingModel(
      id: 'booking-2',
      fieldId: 'field-2',
      userId: 'u1',
      fieldName: 'جول ميكرز (Goal Makers)',
      fieldAddress: 'التجمع الخامس - شارع التسعين',
      fieldImage: 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&q=80&w=800',
      date: '2026-08-04',
      startTime: '17:00',
      endTime: '18:00',
      price: 300.0,
      originalPrice: 300.0,
      discountAmount: 0.0,
      status: 'confirmed',
      bookingCode: '#FT-2026-0804-0015',
    ),
  ];

  /// Get user bookings from Supabase DB or mock fallback
  Future<List<BookingModel>> getBookings() async {
    try {
      final user = _supabase.auth.currentUser;
      var query = _supabase.from('bookings').select('*, football_fields(name, address)');
      if (user != null) {
        query = query.eq('user_id', user.id);
      }
      final response = await query.order('created_at', ascending: false);

      if ((response as List).isNotEmpty) {
        return response.map((item) => BookingModel.fromJson(item)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Supabase getBookings Warning: $e');
    }
    return List.from(_mockBookings);
  }

  /// Get booked start times for a field on a date to dynamically exclude from available slots
  Future<Set<String>> getBookedSlots({
    required String fieldId,
    required String date,
  }) async {
    final Set<String> bookedSlots = {};

    // 1. Add local mock booked slots matching field & date
    for (final b in _mockBookings) {
      if (b.fieldId == fieldId && b.date == date && b.status != 'cancelled') {
        bookedSlots.add(b.startTime);
      }
    }

    // 2. Fetch from Supabase
    try {
      final response = await _supabase
          .from('bookings')
          .select('start_time')
          .eq('field_id', fieldId)
          .eq('booking_date', date)
          .neq('status', 'cancelled');

      for (final item in (response as List)) {
        final timeStr = item['start_time'] as String?;
        if (timeStr != null && timeStr.isNotEmpty) {
          // Time from DB might be '19:00:00' -> trim to '19:00'
          final formattedTime = timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
          bookedSlots.add(formattedTime);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Supabase getBookedSlots Warning: $e');
    }

    return bookedSlots;
  }

  /// Check if a specific slot is available
  Future<bool> checkIsSlotAvailable({
    required String fieldId,
    required String date,
    required String startTime,
  }) async {
    final bookedSlots = await getBookedSlots(fieldId: fieldId, date: date);
    return !bookedSlots.contains(startTime);
  }

  /// Create a new booking with optional coupon code & prices
  Future<BookingModel> createBooking({
    required String fieldId,
    required String fieldName,
    required String fieldAddress,
    required String fieldImage,
    required String date,
    required String startTime,
    required String endTime,
    required double price,
    double? originalPrice,
    double discountAmount = 0.0,
    String? couponCode,
    String? couponId,
  }) async {
    // Prevent Duplicate Booking Check
    final isAvailable = await checkIsSlotAvailable(
      fieldId: fieldId,
      date: date,
      startTime: startTime,
    );

    if (!isAvailable) {
      throw DuplicateBookingFailure('هذا الموعد ($startTime) محجوز بالفعل! يرجى اختيار موعد آخر.');
    }

    User? currentUser;
    try {
      currentUser = _supabase.auth.currentUser;
    } catch (_) {}
    final now = DateTime.now();
    final bookingCode = '#FT-${now.year}-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(1000 + now.millisecond % 9000)}';

    final newBooking = BookingModel(
      id: 'booking-${now.millisecondsSinceEpoch}',
      fieldId: fieldId,
      userId: currentUser?.id ?? 'u1',
      fieldName: fieldName,
      fieldAddress: fieldAddress,
      fieldImage: fieldImage,
      date: date,
      startTime: startTime,
      endTime: endTime,
      price: price,
      originalPrice: originalPrice ?? price,
      discountAmount: discountAmount,
      couponCode: couponCode,
      status: 'confirmed',
      bookingCode: bookingCode,
    );

    // Save to Supabase DB
    try {
      await _supabase.from('bookings').insert(newBooking.toJson());

      // If a valid coupon was applied, increment its usage count
      if (couponId != null && couponId.isNotEmpty) {
        await _couponRepository.incrementCouponUsage(couponId);
      }
    } catch (e) {
      if (kDebugMode) print('Supabase createBooking insert warning: $e');
    }

    // Insert locally for immediate ui reflection
    _mockBookings.insert(0, newBooking);

    // Add confirmation notification
    try {
      await NotificationRepository().addNotification(
        title: 'تم تأكيد حجز جديد! ⚽',
        body: 'تم تأكيد حجز ملعب "$fieldName" يوم $date الساعة $startTime. كود الحجز: $bookingCode',
        type: NotificationType.booking,
        targetId: fieldId,
      );
    } catch (e) {
      if (kDebugMode) print('Notification warning: $e');
    }

    return newBooking;
  }

  /// Cancel an existing booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _supabase.from('bookings').update({'status': 'cancelled'}).eq('id', bookingId);
    } catch (e) {
      if (kDebugMode) print('Supabase cancelBooking Warning: $e');
    }

    final index = _mockBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _mockBookings[index] = _mockBookings[index].copyWith(status: 'cancelled');
    }
  }
}
