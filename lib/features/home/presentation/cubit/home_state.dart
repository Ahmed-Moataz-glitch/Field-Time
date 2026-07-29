import 'package:equatable/equatable.dart';
import 'package:field_time/features/home/data/models/field_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<FieldModel> fields;
  final String selectedCategory;
  final String searchQuery;

  const HomeLoaded({
    required this.fields,
    this.selectedCategory = 'كل الملاعب',
    this.searchQuery = '',
  });

  HomeLoaded copyWith({
    List<FieldModel>? fields,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return HomeLoaded(
      fields: fields ?? this.fields,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [fields, selectedCategory, searchQuery];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
