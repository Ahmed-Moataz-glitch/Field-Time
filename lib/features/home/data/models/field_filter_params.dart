import 'package:equatable/equatable.dart';

class FieldFilterParams extends Equatable {
  final String? city;
  final String? searchQuery;
  final String? fieldType; // e.g. خماسي, سباعي, 11v11
  final String? grassType; // e.g. عشب صناعي, عشب طبيعي, ترتان
  final double? maxPrice;
  final double? minRating;
  final bool? isIndoor;
  final bool? isAvailableToday;

  const FieldFilterParams({
    this.city,
    this.searchQuery,
    this.fieldType,
    this.grassType,
    this.maxPrice,
    this.minRating,
    this.isIndoor,
    this.isAvailableToday,
  });

  bool get hasActiveFilters {
    return (city != null && city != 'جميع المدن') ||
        (searchQuery != null && searchQuery!.isNotEmpty) ||
        fieldType != null ||
        grassType != null ||
        maxPrice != null ||
        (minRating != null && minRating! > 0) ||
        (isIndoor != null && isIndoor == true) ||
        (isAvailableToday != null && isAvailableToday == true);
  }

  FieldFilterParams copyWith({
    String? city,
    String? searchQuery,
    String? fieldType,
    String? grassType,
    double? maxPrice,
    double? minRating,
    bool? isIndoor,
    bool? isAvailableToday,
  }) {
    return FieldFilterParams(
      city: city ?? this.city,
      searchQuery: searchQuery ?? this.searchQuery,
      fieldType: fieldType ?? this.fieldType,
      grassType: grassType ?? this.grassType,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      isIndoor: isIndoor ?? this.isIndoor,
      isAvailableToday: isAvailableToday ?? this.isAvailableToday,
    );
  }

  FieldFilterParams clear() {
    return const FieldFilterParams();
  }

  @override
  List<Object?> get props => [
        city,
        searchQuery,
        fieldType,
        grassType,
        maxPrice,
        minRating,
        isIndoor,
        isAvailableToday,
      ];
}
