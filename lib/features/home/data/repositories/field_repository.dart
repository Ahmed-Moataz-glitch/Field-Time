import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/features/home/data/models/field_model.dart';
import 'package:field_time/features/home/data/models/offer_model.dart';
import 'package:field_time/features/home/data/models/field_filter_params.dart';
import 'package:field_time/features/field_details/data/models/review_model.dart';

class FieldRepository {
  final SupabaseClient _supabase;

  FieldRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  static const List<OfferModel> _mockOffers = [
    OfferModel(
      id: 'offer-1',
      title: 'خصم 25% على حجوزات المنتصف',
      subtitle: 'احجز أي ملعب خماسي من الأحد إلى الأربعاء واستمتع بالخصم!',
      discountText: '25% خصم',
      imageUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
      tag: 'عرض الأسبوع',
      fieldId: 'field-1',
    ),
    OfferModel(
      id: 'offer-2',
      title: 'ساعات الليل الذهبية',
      subtitle: 'احجز بعد الساعة 11 مساءً وحصّل على خصم 50 جنيه/ساعة',
      discountText: 'خصم 50 ج.م',
      imageUrl: 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&q=80&w=800',
      tag: 'عرض السهرة',
      fieldId: 'field-2',
    ),
    OfferModel(
      id: 'offer-3',
      title: 'دوري الويك إند المثير',
      subtitle: 'احجز ملاعبنا السباعية يومي الجمعة والسبت بأسعار خاصة',
      discountText: 'عروض المجموعات',
      imageUrl: 'https://images.unsplash.com/photo-1556056504-5c7696c4c28d?auto=format&fit=crop&q=80&w=800',
      tag: 'عروض الويك إند',
      fieldId: 'field-3',
    ),
  ];

  static const List<FieldModel> _mockFields = [
    FieldModel(
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
        'https://images.unsplash.com/photo-1556056504-5c7696c4c28d?auto=format&fit=crop&q=80&w=800',
      ],
      facilities: ['إضاءة ليلية', 'مواقف سيارات', 'دورات مياه', 'مقهى', 'غرف تبديل'],
      isFavorite: true,
      isPopular: true,
      isRecommended: true,
      isAvailableToday: true,
      phone: '01012345678',
    ),
    FieldModel(
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
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
      ],
      facilities: ['إضاءة ليلية', 'دورات مياه', 'مواقف سيارات'],
      isFavorite: false,
      isPopular: true,
      isRecommended: false,
      isAvailableToday: true,
      phone: '01123456789',
    ),
    FieldModel(
      id: 'field-3',
      name: 'فيكتوري ستاديوم (Victory Field)',
      description: 'ملعب سباعي مميز ومجهز بالكامل مع إمكانية تنظيم الدوريات والمباريات الكبيرة.',
      city: 'القاهرة',
      area: 'مصر الجديدة',
      address: 'مصر الجديدة - شارع الميرغني',
      pricePerHour: 450.0,
      oldPrice: 500.0,
      rating: 4.9,
      reviewsCount: 210,
      distance: '3.4 كم',
      fieldType: 'سباعي',
      grassType: 'عشب صناعي',
      isIndoor: false,
      mainImage: 'https://images.unsplash.com/photo-1556056504-5c7696c4c28d?auto=format&fit=crop&q=80&w=800',
      images: [
        'https://images.unsplash.com/photo-1556056504-5c7696c4c28d?auto=format&fit=crop&q=80&w=800',
      ],
      facilities: ['إضاءة ليلية', 'مواقف سيارات', 'مقهى', 'غرف تبديل ملابس'],
      isFavorite: true,
      isPopular: true,
      isRecommended: true,
      isAvailableToday: true,
      phone: '01234567890',
    ),
    FieldModel(
      id: 'field-4',
      name: 'المكشوف إن دادي (InDoor Dome)',
      description: 'صالة كروية مغطاة ومكيفة بالكامل ومجهزة بأرضية ترتان عالمية لحماية اللاعبين من الإصابات.',
      city: 'الجيزة',
      area: '6 أكتوبر',
      address: '6 أكتوبر - المحور المركزي',
      pricePerHour: 500.0,
      oldPrice: 600.0,
      rating: 4.7,
      reviewsCount: 76,
      distance: '5.0 كم',
      fieldType: 'خماسي',
      grassType: 'ترتان',
      isIndoor: true,
      mainImage: 'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?auto=format&fit=crop&q=80&w=800',
      images: [
        'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?auto=format&fit=crop&q=80&w=800',
      ],
      facilities: ['تكييف هوائي', 'إضاءة ليلية', 'مواقف سيارات', 'مقهى VIP'],
      isFavorite: false,
      isPopular: false,
      isRecommended: true,
      isAvailableToday: true,
      phone: '01512345678',
    ),
    FieldModel(
      id: 'field-5',
      name: 'القرية الأولمبية (Olympic Park)',
      description: 'ملعب قانوني 11 ضد 11 بأرضية نجيل طبيعي ممتازة مع مدرجات مشجعين.',
      city: 'الإسكندرية',
      area: 'سموحة',
      address: 'الإسكندرية - سموحة - شارع فوزي معاذ',
      pricePerHour: 800.0,
      oldPrice: 950.0,
      rating: 4.9,
      reviewsCount: 310,
      distance: '8.5 كم',
      fieldType: '11v11',
      grassType: 'عشب طبيعي',
      isIndoor: false,
      mainImage: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&q=80&w=800',
      images: [
        'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&q=80&w=800',
      ],
      facilities: ['نجيل طبيعي', 'مدرجات', 'إضاءة كاشفة', 'مواقف سيارات', 'غرف تبديل'],
      isFavorite: false,
      isPopular: true,
      isRecommended: true,
      isAvailableToday: false,
      phone: '01099887766',
    ),
  ];

  Future<List<OfferModel>> getOffers() async {
    try {
      final response = await _supabase.from('offers').select();
      if ((response as List).isNotEmpty) {
        return response.map((item) => OfferModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return _mockOffers;
  }

  Future<List<FieldModel>> getFields({
    String? category,
    String? searchQuery,
    FieldFilterParams? filterParams,
  }) async {
    try {
      final response = await _supabase.from('football_fields').select('*, field_images(*)');
      if ((response as List).isNotEmpty) {
        final fields = response.map((item) => FieldModel.fromJson(item)).toList();
        return filterFieldList(fields, category: category, searchQuery: searchQuery, filterParams: filterParams);
      }
    } catch (_) {}
    return filterFieldList(_mockFields, category: category, searchQuery: searchQuery, filterParams: filterParams);
  }

  Future<List<FieldModel>> getPopularFields() async {
    final fields = await getFields();
    return fields.where((f) => f.isPopular || f.rating >= 4.6).toList();
  }

  Future<List<FieldModel>> getNearbyFields({String? city}) async {
    final fields = await getFields();
    if (city != null && city != 'جميع المدن') {
      final filtered = fields.where((f) => f.city == city || f.area.contains(city)).toList();
      if (filtered.isNotEmpty) return filtered;
    }
    return fields;
  }

  Future<List<FieldModel>> getRecommendedFields() async {
    final fields = await getFields();
    return fields.where((f) => f.isRecommended || f.reviewsCount > 90).toList();
  }

  List<FieldModel> filterFieldList(
    List<FieldModel> fields, {
    String? category,
    String? searchQuery,
    FieldFilterParams? filterParams,
  }) {
    var result = fields;

    // 1. Category Filter
    if (category != null && category != 'كل الملاعب') {
      if (category == 'صالات') {
        result = result.where((f) => f.isIndoor).toList();
      } else if (category == 'العروض') {
        result = result.where((f) => f.oldPrice != null).toList();
      } else {
        result = result.where((f) => f.fieldType == category).toList();
      }
    }

    // 2. Search Query Filter
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      result = result.where((f) {
        return f.name.toLowerCase().contains(query) ||
            f.city.toLowerCase().contains(query) ||
            f.area.toLowerCase().contains(query) ||
            f.address.toLowerCase().contains(query);
      }).toList();
    }

    // 3. Filter Params
    if (filterParams != null) {
      if (filterParams.city != null && filterParams.city != 'جميع المدن') {
        result = result.where((f) => f.city == filterParams.city || f.area.contains(filterParams.city!)).toList();
      }
      if (filterParams.fieldType != null) {
        result = result.where((f) => f.fieldType == filterParams.fieldType).toList();
      }
      if (filterParams.grassType != null) {
        result = result.where((f) => f.grassType == filterParams.grassType).toList();
      }
      if (filterParams.maxPrice != null && filterParams.maxPrice! > 0) {
        result = result.where((f) => f.pricePerHour <= filterParams.maxPrice!).toList();
      }
      if (filterParams.minRating != null && filterParams.minRating! > 0) {
        result = result.where((f) => f.rating >= filterParams.minRating!).toList();
      }
      if (filterParams.isIndoor != null && filterParams.isIndoor!) {
        result = result.where((f) => f.isIndoor).toList();
      }
      if (filterParams.isAvailableToday != null && filterParams.isAvailableToday!) {
        result = result.where((f) => f.isAvailableToday).toList();
      }
    }

    return result;
  }

  Future<FieldModel?> getFieldById(String id) async {
    try {
      final response = await _supabase
          .from('football_fields')
          .select('*, field_images(*)')
          .eq('id', id)
          .single();
      return FieldModel.fromJson(response);
    } catch (_) {}
    try {
      return _mockFields.firstWhere((f) => f.id == id);
    } catch (_) {
      return _mockFields.first;
    }
  }

  Future<bool> toggleFavorite(String fieldId, String userId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('field_id', fieldId);

      if ((response as List).isNotEmpty) {
        await _supabase.from('favorites').delete().eq('user_id', userId).eq('field_id', fieldId);
        return false;
      } else {
        await _supabase.from('favorites').insert({
          'user_id': userId,
          'field_id': fieldId,
        });
        return true;
      }
    } catch (_) {
      return true;
    }
  }

  Future<List<ReviewModel>> getReviewsByFieldId(String fieldId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*, users(full_name, avatar_url)')
          .eq('field_id', fieldId)
          .order('created_at', ascending: false);
      if ((response as List).isNotEmpty) {
        return response.map((item) => ReviewModel.fromJson(item)).toList();
      }
    } catch (_) {}

    return const [
      ReviewModel(
        id: 'rev-1',
        userId: 'u1',
        userName: 'أحمد محمود',
        userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200',
        rating: 5.0,
        comment: 'ملعب ممتاز جداً والنجيل الصناعي جودته عالية والإضاءة ممتازة ليلاً. ننصح باللعب فيه!',
        createdAt: 'منذ 3 أيام',
      ),
      ReviewModel(
        id: 'rev-2',
        userId: 'u2',
        userName: 'مصطفى حسن',
        userAvatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&q=80&w=200',
        rating: 4.5,
        comment: 'المكان نظيف وغرف التبديل مرتبة، ولكن يفضل زيادة أماكن وركن السيارات.',
        createdAt: 'منذ أسبوع',
      ),
      ReviewModel(
        id: 'rev-3',
        userId: 'u3',
        userName: 'عمر خالد',
        userAvatar: null,
        rating: 5.0,
        comment: 'خدمة حجز سريعة وتعامل راقي من إدارة الملعب.',
        createdAt: 'منذ أسبوعين',
      ),
    ];
  }
}

