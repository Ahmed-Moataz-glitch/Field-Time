import 'package:equatable/equatable.dart';
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
  final String selectedDate;
  final String? selectedTimeSlot;

  const FieldDetailsLoaded({
    required this.field,
    required this.selectedDate,
    this.selectedTimeSlot,
  });

  FieldDetailsLoaded copyWith({
    FieldModel? field,
    String? selectedDate,
    String? selectedTimeSlot,
  }) {
    return FieldDetailsLoaded(
      field: field ?? this.field,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
    );
  }

  @override
  List<Object?> get props => [field, selectedDate, selectedTimeSlot];
}

class FieldDetailsError extends FieldDetailsState {
  final String message;

  const FieldDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
