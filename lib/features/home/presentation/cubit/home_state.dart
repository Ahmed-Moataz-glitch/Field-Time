import 'package:equatable/equatable.dart';
import 'package:field_time/features/home/data/models/field_filter_params.dart';
import 'package:field_time/features/home/data/models/field_model.dart';
import 'package:field_time/features/home/data/models/offer_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<OfferModel> offers;
  final List<FieldModel> popularFields;
  final List<FieldModel> nearbyFields;
  final List<FieldModel> recommendedFields;
  final List<FieldModel> filteredFields;
  final String selectedCategory;
  final String searchQuery;
  final FieldFilterParams filterParams;
  final String selectedCity;
  final Set<String> favoriteFieldIds;
  final bool isRefreshing;

  const HomeLoaded({
    required this.offers,
    required this.popularFields,
    required this.nearbyFields,
    required this.recommendedFields,
    required this.filteredFields,
    this.selectedCategory = 'كل الملاعب',
    this.searchQuery = '',
    this.filterParams = const FieldFilterParams(),
    this.selectedCity = 'القاهرة',
    this.favoriteFieldIds = const {},
    this.isRefreshing = false,
  });

  HomeLoaded copyWith({
    List<OfferModel>? offers,
    List<FieldModel>? popularFields,
    List<FieldModel>? nearbyFields,
    List<FieldModel>? recommendedFields,
    List<FieldModel>? filteredFields,
    String? selectedCategory,
    String? searchQuery,
    FieldFilterParams? filterParams,
    String? selectedCity,
    Set<String>? favoriteFieldIds,
    bool? isRefreshing,
  }) {
    return HomeLoaded(
      offers: offers ?? this.offers,
      popularFields: popularFields ?? this.popularFields,
      nearbyFields: nearbyFields ?? this.nearbyFields,
      recommendedFields: recommendedFields ?? this.recommendedFields,
      filteredFields: filteredFields ?? this.filteredFields,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      filterParams: filterParams ?? this.filterParams,
      selectedCity: selectedCity ?? this.selectedCity,
      favoriteFieldIds: favoriteFieldIds ?? this.favoriteFieldIds,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        offers,
        popularFields,
        nearbyFields,
        recommendedFields,
        filteredFields,
        selectedCategory,
        searchQuery,
        filterParams,
        selectedCity,
        favoriteFieldIds,
        isRefreshing,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
