import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/core/errors/failures.dart';
import 'package:field_time/features/home/data/models/field_model.dart';
import 'package:field_time/features/owner_dashboard/data/repositories/owner_repository.dart';
import 'package:field_time/features/owner_dashboard/presentation/cubit/owner_dashboard_state.dart';

class OwnerDashboardCubit extends Cubit<OwnerDashboardState> {
  final OwnerRepository _repository;

  OwnerDashboardCubit(this._repository) : super(OwnerDashboardInitial());

  Future<void> loadDashboardData() async {
    emit(OwnerDashboardLoading());
    try {
      final fields = await _repository.getOwnerFields();
      final bookings = await _repository.getOwnerBookings();
      final stats = await _repository.getOwnerStats();

      emit(OwnerDashboardLoaded(
        fields: fields,
        bookings: bookings,
        stats: stats,
      ));
    } catch (e) {
      emit(OwnerDashboardError(e.toString()));
    }
  }

  Future<void> addField(FieldModel field) async {
    try {
      await _repository.addFootballField(field);
      emit(const OwnerOperationSuccess('تم إضافة الملعب بنجاح! 🎉'));
      await loadDashboardData();
    } catch (e) {
      emit(OwnerDashboardError('فشل إضافة الملعب: ${e.toString()}'));
    }
  }

  Future<void> updateField(FieldModel field) async {
    try {
      await _repository.updateFootballField(field);
      emit(const OwnerOperationSuccess('تم تحديث بيانات الملعب بنجاح!'));
      await loadDashboardData();
    } catch (e) {
      emit(OwnerDashboardError('فشل تعديل بيانات الملعب: ${e.toString()}'));
    }
  }

  Future<void> deleteField(String fieldId) async {
    try {
      await _repository.deleteFootballField(fieldId);
      emit(const OwnerOperationSuccess('تم حذف الملعب بنجاح'));
      await loadDashboardData();
    } on ServerFailure catch (e) {
      emit(OwnerDashboardError(e.message));
    } catch (e) {
      emit(OwnerDashboardError('فشل حذف الملعب: ${e.toString()}'));
    }
  }

  Future<void> toggleFieldAvailability(String fieldId, bool isAvailable) async {
    try {
      await _repository.toggleFieldAvailability(fieldId, isAvailable);
      await loadDashboardData();
    } catch (_) {}
  }
}
