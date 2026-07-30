import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/core/errors/failures.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';
import 'package:field_time/features/home/data/models/field_model.dart';
import 'package:field_time/features/owner_dashboard/data/models/owner_stats_model.dart';

class OwnerRepository {
  final SupabaseClient _supabase;

  OwnerRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  static final List<FieldModel> _mockOwnerFields = [
    const FieldModel(
      id: 'field-1',
      name: 'أرينا سبورت (Arena Sport)',
      description: 'ملعب خماسي مجهز بأعلى المستويات وأرضية نجيل صناعي ممتازة مع إضاءة ليلية متطورة وغرف تبديل ملابس واسعة ومقاهي جانبية.',
      city: 'القاهرة',
      area: 'مدينة نصر',
      address: 'مدينة نصر - شارع الطيران - بجوار النادي الأهلي',
      pricePerHour: 350.0,
      oldPrice: 420.0,
      rating: 4.8,
      reviewsCount: 142,
      distance: '1.2 كم',
      fieldType: 'خماسي',
      grassType: 'عشب صناعي',
      isIndoor: false,
      mainImage: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
      images: [
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
        'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&q=80&w=800',
      ],
      facilities: ['إضاءة ليلية', 'مواقف سيارات', 'دورات مياه', 'مقهى', 'غرف تبديل'],
      isFavorite: true,
      isPopular: true,
      isRecommended: true,
      isAvailableToday: true,
      phone: '01012345678',
    ),
    const FieldModel(
      id: 'field-2',
      name: 'جول ميكرز (Goal Makers)',
      description: 'ملعب خماسي متميز بالنجيل الصناعي عالي الجودة ومناسب للمباريات التنافسية والدوريات الأسبوعية.',
      city: 'القاهرة',
      area: 'التجمع الخامس',
      address: 'التجمع الخامس - شارع التسعين الشمالي',
      pricePerHour: 300.0,
      oldPrice: 380.0,
      rating: 4.6,
      reviewsCount: 98,
      distance: '2.1 كم',
      fieldType: 'خماسي',
      grassType: 'عشب صناعي',
      isIndoor: false,
      mainImage: 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&q=80&w=800',
      images: [
        'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&q=80&w=800',
      ],
      facilities: ['إضاءة ليلية', 'دورات مياه', 'مواقف سيارات'],
      isFavorite: false,
      isPopular: true,
      isRecommended: false,
      isAvailableToday: true,
      phone: '01123456789',
    ),
  ];

  static final List<BookingModel> _mockOwnerBookings = [
    const BookingModel(
      id: 'b-owner-1',
      fieldId: 'field-1',
      fieldName: 'أرينا سبورت (Arena Sport)',
      fieldAddress: 'مدينة نصر - شارع الطيران',
      fieldImage: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
      date: '2026-07-31',
      startTime: '19:00',
      endTime: '20:00',
      price: 350.0,
      status: 'confirmed',
      bookingCode: '#FT-2026-0731-0101',
    ),
    const BookingModel(
      id: 'b-owner-2',
      fieldId: 'field-1',
      fieldName: 'أرينا سبورت (Arena Sport)',
      fieldAddress: 'مدينة نصر - شارع الطيران',
      fieldImage: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
      date: '2026-07-31',
      startTime: '21:00',
      endTime: '22:00',
      price: 350.0,
      status: 'confirmed',
      bookingCode: '#FT-2026-0731-0102',
    ),
    const BookingModel(
      id: 'b-owner-3',
      fieldId: 'field-2',
      fieldName: 'جول ميكرز (Goal Makers)',
      fieldAddress: 'التجمع الخامس - شارع التسعين',
      fieldImage: 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&q=80&w=800',
      date: '2026-07-30',
      startTime: '18:00',
      endTime: '19:00',
      price: 300.0,
      status: 'completed',
      bookingCode: '#FT-2026-0730-0089',
    ),
  ];

  Future<List<FieldModel>> getOwnerFields() async {
    try {
      final response = await _supabase.from('football_fields').select('*, field_images(*)');
      if ((response as List).isNotEmpty) {
        return response.map((item) => FieldModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return List.from(_mockOwnerFields);
  }

  Future<List<BookingModel>> getOwnerBookings() async {
    try {
      final response = await _supabase.from('bookings').select('*');
      if ((response as List).isNotEmpty) {
        return response.map((item) => BookingModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return List.from(_mockOwnerBookings);
  }

  Future<OwnerStatsModel> getOwnerStats() async {
    final fields = await getOwnerFields();
    final bookings = await getOwnerBookings();

    final activeCount = fields.where((f) => f.isAvailableToday).length;
    final totalEarnings = bookings
        .where((b) => b.status != 'cancelled')
        .fold(0.0, (sum, item) => sum + item.price);

    return OwnerStatsModel(
      totalEarnings: totalEarnings > 0 ? totalEarnings : 14850.0,
      totalBookings: bookings.isNotEmpty ? bookings.length : 42,
      activeFieldsCount: activeCount > 0 ? activeCount : fields.length,
      occupancyRate: 84.5,
      monthlyRevenue: const [
        RevenueDataPoint(month: 'يناير', revenue: 12000.0),
        RevenueDataPoint(month: 'فبراير', revenue: 13500.0),
        RevenueDataPoint(month: 'مارس', revenue: 15000.0),
        RevenueDataPoint(month: 'أبريل', revenue: 14200.0),
        RevenueDataPoint(month: 'مايو', revenue: 16800.0),
        RevenueDataPoint(month: 'يونيو', revenue: 18500.0),
        RevenueDataPoint(month: 'يوليو', revenue: 14850.0),
      ],
    );
  }

  Future<FieldModel> addFootballField(FieldModel field) async {
    final id = 'field-${DateTime.now().millisecondsSinceEpoch}';
    final newField = field.copyWith(id: id);

    try {
      await _supabase.from('football_fields').insert(newField.toJson());
    } catch (_) {}

    _mockOwnerFields.insert(0, newField);
    return newField;
  }

  Future<FieldModel> updateFootballField(FieldModel field) async {
    try {
      await _supabase.from('football_fields').update(field.toJson()).eq('id', field.id);
    } catch (_) {}

    final index = _mockOwnerFields.indexWhere((f) => f.id == field.id);
    if (index != -1) {
      _mockOwnerFields[index] = field;
    }
    return field;
  }

  Future<void> deleteFootballField(String fieldId) async {
    // Safety Policy Check: Verify if field has active confirmed bookings
    final bookings = await getOwnerBookings();
    final hasActiveBookings = bookings.any(
      (b) => b.fieldId == fieldId && b.status == 'confirmed',
    );

    if (hasActiveBookings) {
      throw const ServerFailure('لا يمكن حذف هذا الملعب لوجود حجوزات مؤكدة وقائمة عليه!');
    }

    try {
      await _supabase.from('football_fields').delete().eq('id', fieldId);
    } catch (_) {}

    _mockOwnerFields.removeWhere((f) => f.id == fieldId);
  }

  Future<void> toggleFieldAvailability(String fieldId, bool isAvailable) async {
    final index = _mockOwnerFields.indexWhere((f) => f.id == fieldId);
    if (index != -1) {
      final updated = _mockOwnerFields[index].copyWith(isAvailableToday: isAvailable);
      _mockOwnerFields[index] = updated;

      try {
        await _supabase
            .from('football_fields')
            .update({'is_active': isAvailable})
            .eq('id', fieldId);
      } catch (_) {}
    }
  }
}
