import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/features/home/data/repositories/field_repository.dart';
import 'package:field_time/features/field_details/presentation/cubit/field_details_state.dart';

class FieldDetailsCubit extends Cubit<FieldDetailsState> {
  final FieldRepository _repository;

  FieldDetailsCubit(this._repository) : super(FieldDetailsInitial());

  Future<void> loadFieldDetails(String fieldId) async {
    emit(FieldDetailsLoading());
    try {
      final field = await _repository.getFieldById(fieldId);
      if (field != null) {
        emit(FieldDetailsLoaded(
          field: field,
          selectedDate: 'الجمعة 24 مايو',
          selectedTimeSlot: '11:00',
        ));
      } else {
        emit(const FieldDetailsError('الملعب غير موجود'));
      }
    } catch (e) {
      emit(FieldDetailsError(e.toString()));
    }
  }

  void selectDate(String date) {
    if (state is FieldDetailsLoaded) {
      final currentState = state as FieldDetailsLoaded;
      emit(currentState.copyWith(selectedDate: date));
    }
  }

  void selectTimeSlot(String timeSlot) {
    if (state is FieldDetailsLoaded) {
      final currentState = state as FieldDetailsLoaded;
      emit(currentState.copyWith(selectedTimeSlot: timeSlot));
    }
  }
}
