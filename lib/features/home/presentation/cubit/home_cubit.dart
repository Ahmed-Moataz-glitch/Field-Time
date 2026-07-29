import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/features/home/data/repositories/field_repository.dart';
import 'package:field_time/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FieldRepository _repository;

  HomeCubit(this._repository) : super(HomeInitial());

  Future<void> loadHomeData({String? category, String? searchQuery}) async {
    emit(HomeLoading());
    try {
      final fields = await _repository.getFields(
        category: category,
        searchQuery: searchQuery,
      );
      emit(HomeLoaded(
        fields: fields,
        selectedCategory: category ?? 'كل الملاعب',
        searchQuery: searchQuery ?? '',
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void selectCategory(String category) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      loadHomeData(
        category: category,
        searchQuery: currentState.searchQuery,
      );
    } else {
      loadHomeData(category: category);
    }
  }

  void searchFields(String query) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      loadHomeData(
        category: currentState.selectedCategory,
        searchQuery: query,
      );
    } else {
      loadHomeData(searchQuery: query);
    }
  }
}
