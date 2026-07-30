import 'package:equatable/equatable.dart';
import 'package:field_time/features/field_details/data/models/review_model.dart';
import 'package:field_time/features/home/data/models/field_model.dart';

abstract class FieldDetailsState extends Equatable {
  const FieldDetailsState();

  @override
  List<Object?> get props => [];
}

class FieldDetailsInitial extends FieldDetailsState {}

class FieldDetailsLoading extends FieldDetailsState {}

class FieldDetailsLoaded extends FieldDetailsState {
  final FieldModel field;
  final List<ReviewModel> reviews;
  final List<FieldModel> relatedFields;
  final String selectedDate;
  final String? selectedTimeSlot;
  final int currentImageIndex;
  final bool isFavorite;
  final bool isDescriptionExpanded;

  const FieldDetailsLoaded({
    required this.field,
    required this.reviews,
    required this.relatedFields,
    required this.selectedDate,
    this.selectedTimeSlot,
    this.currentImageIndex = 0,
    required this.isFavorite,
    this.isDescriptionExpanded = false,
  });

  FieldDetailsLoaded copyWith({
    FieldModel? field,
    List<ReviewModel>? reviews,
    List<FieldModel>? relatedFields,
    String? selectedDate,
    String? selectedTimeSlot,
    int? currentImageIndex,
    bool? isFavorite,
    bool? isDescriptionExpanded,
  }) {
    return FieldDetailsLoaded(
      field: field ?? this.field,
      reviews: reviews ?? this.reviews,
      relatedFields: relatedFields ?? this.relatedFields,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
      isFavorite: isFavorite ?? this.isFavorite,
      isDescriptionExpanded: isDescriptionExpanded ?? this.isDescriptionExpanded,
    );
  }

  @override
  List<Object?> get props => [
        field,
        reviews,
        relatedFields,
        selectedDate,
        selectedTimeSlot,
        currentImageIndex,
        isFavorite,
        isDescriptionExpanded,
      ];
}

class FieldDetailsError extends FieldDetailsState {
  final String message;

  const FieldDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
