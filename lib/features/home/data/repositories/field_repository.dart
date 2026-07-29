import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/features/home/data/models/field_model.dart';

class FieldRepository {
  final SupabaseClient _supabase;

  FieldRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  static const List<FieldModel> _mockFields = [
    FieldModel(
      id: 'field-1',
      name: 'Arena Sport',
      description: 'ملعب خماسي مجهز بأعلى المستويات وأرضية نجيل صناعي ممتازة مع إضاءة ليلية متطورة وغرف تبديل ملابس واسعة.',
      city: 'القاهرة',
      area: 'مدينة نصر',
      address: 'مدينة نصر - شارع الطيران',
      pricePerHour: 350.0,
      oldPrice: 400.0,
      rating: 4.7,
      reviewsCount: 120,
      distance: '1.2 كم',
      fieldType: 'خماسي',
      grassType: 'عشب صناعي',
      isIndoor: false,
      mainImage: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
      images: [
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
        'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&q=80&w=800',
        'https://images.unsplash.com/photo-1556056504-5c7696c4c28d?auto=format&fit=crop&q=80&w=800',
        'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?auto=format&fit=crop&q=80&w=800',
      ],
      facilities: ['إضاءة ليلية', 'مواقف سيارات', 'دورات مياه', 'مقهى'],
      isFavorite: true,
    ),
    FieldModel(
      id: 'field-2',
      name: 'Goal Makers',
      description: 'ملعب خماسي متميز بالنجيل الصناعي عالي الجودة ومناسب للمباريات التنافسية والدوريات.',
      city: 'القاهرة',
      area: 'التجمع الخامس',
      address: 'التجمع الخامس - شارع التسعين',
      pricePerHour: 300.0,
      oldPrice: 350.0,
      rating: 4.5,
      reviewsCount: 85,
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
    ),
    FieldModel(
      id: 'field-3',
      name: 'Victory Field',
      description: 'ملعب سباعي مميز ومجهز بالكامل مع إمكانية تنظيم الدوريات والمباريات الكبيرة.',
      city: 'القاهرة',
      area: 'مصر الجديدة',
      address: 'مصر الجديدة - الميرغني',
      pricePerHour: 400.0,
      oldPrice: 450.0,
      rating: 4.6,
      reviewsCount: 94,
      distance: '3.4 كم',
      fieldType: 'سباعي',
      grassType: 'عشب صناعي',
      isIndoor: false,
      mainImage: 'https://images.unsplash.com/photo-1556056504-5c7696c4c28d?auto=format&fit=crop&q=80&w=800',
      images: [
        'https://images.unsplash.com/photo-1556056504-5c7696c4c28d?auto=format&fit=crop&q=80&w=800',
      ],
      facilities: ['إضاءة ليلية', 'مواقف سيارات', 'مقهى', 'غرف تبديل ملابس'],
      isFavorite: false,
    ),
  ];

  Future<List<FieldModel>> getFields({String? category, String? searchQuery}) async {
    try {
      final response = await _supabase.from('football_fields').select('*, field_images(*)');
      if ((response as List).isNotEmpty) {
        final fields = response.map((item) => FieldModel.fromJson(item)).toList();
        return _filterFields(fields, category, searchQuery);
      }
    } catch (_) {}
    return _filterFields(_mockFields, category, searchQuery);
  }

  List<FieldModel> _filterFields(List<FieldModel> fields, String? category, String? searchQuery) {
    var result = fields;
    if (category != null && category != 'كل الملاعب') {
      result = result.where((f) => f.fieldType == category || (category == 'صالات' && f.isIndoor)).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((f) => f.name.toLowerCase().contains(query) || f.area.toLowerCase().contains(query)).toList();
    }
    return result;
  }

  Future<FieldModel?> getFieldById(String id) async {
    try {
      final response = await _supabase.from('football_fields').select('*, field_images(*)').eq('id', id).single();
      return FieldModel.fromJson(response);
    } catch (_) {}
    return _mockFields.firstWhere((f) => f.id == id, orElse: () => _mockFields.first);
  }
}
