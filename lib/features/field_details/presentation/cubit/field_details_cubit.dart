import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:field_time/features/field_details/presentation/cubit/field_details_state.dart';
import 'package:field_time/features/home/data/repositories/field_repository.dart';

class FieldDetailsCubit extends Cubit<FieldDetailsState> {
  final FieldRepository _repository;

  FieldDetailsCubit(this._repository) : super(FieldDetailsInitial());

  Future<void> loadFieldDetails(String fieldId) async {
    emit(FieldDetailsLoading());
    try {
      final field = await _repository.getFieldById(fieldId);
      if (field != null) {
        final reviews = await _repository.getReviewsByFieldId(fieldId);
        final allFields = await _repository.getFields();
        final related = allFields.where((f) => f.id != fieldId).take(4).toList();

        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

        emit(FieldDetailsLoaded(
          field: field,
          reviews: reviews,
          relatedFields: related,
          selectedDate: todayStr,
          selectedTimeSlot: '18:00',
          currentImageIndex: 0,
          isFavorite: field.isFavorite,
          isDescriptionExpanded: false,
        ));
      } else {
        emit(const FieldDetailsError('الملعب غير موجود'));
      }
    } catch (e) {
      emit(FieldDetailsError('فشل تحميل تفاصيل الملعب: ${e.toString()}'));
    }
  }

  void changeImageIndex(int index) {
    if (state is FieldDetailsLoaded) {
      final currentState = state as FieldDetailsLoaded;
      emit(currentState.copyWith(currentImageIndex: index));
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

  void toggleDescriptionExpand() {
    if (state is FieldDetailsLoaded) {
      final currentState = state as FieldDetailsLoaded;
      emit(currentState.copyWith(isDescriptionExpanded: !currentState.isDescriptionExpanded));
    }
  }

  Future<void> toggleFavorite() async {
    if (state is FieldDetailsLoaded) {
      final currentState = state as FieldDetailsLoaded;
      try {
        final isFavNow = await _repository.toggleFavorite(currentState.field.id);
        emit(currentState.copyWith(
          isFavorite: isFavNow,
          field: currentState.field.copyWith(isFavorite: isFavNow),
        ));
      } catch (_) {}
    }
  }
}
