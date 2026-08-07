import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/features/home/data/models/field_filter_params.dart';
import 'package:field_time/features/home/data/models/field_model.dart';
import 'package:field_time/features/home/data/repositories/field_repository.dart';
import 'package:field_time/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FieldRepository _repository;

  HomeCubit(this._repository) : super(HomeInitial());

  Future<void> loadHomeData({bool isRefresh = false}) async {
    final currentLoaded = state is HomeLoaded ? (state as HomeLoaded) : null;
    if (isRefresh && currentLoaded != null) {
      emit(currentLoaded.copyWith(isRefreshing: true));
    } else if (currentLoaded == null) {
      emit(HomeLoading());
    }

    try {
      final selectedCategory = currentLoaded?.selectedCategory ?? 'كل الملاعب';
      final searchQuery = currentLoaded?.searchQuery ?? '';
      final filterParams = currentLoaded?.filterParams ?? const FieldFilterParams();
      final selectedCity = currentLoaded?.selectedCity ?? 'القاهرة';

      final offersFuture = _repository.getOffers();
      final popularFuture = _repository.getPopularFields();
      final nearbyFuture = _repository.getNearbyFields(city: selectedCity);
      final recommendedFuture = _repository.getRecommendedFields();
      final filteredFuture = _repository.getFields(
        category: selectedCategory,
        searchQuery: searchQuery,
        filterParams: filterParams,
      );

      final results = await Future.wait([
        offersFuture,
        popularFuture,
        nearbyFuture,
        recommendedFuture,
        filteredFuture,
      ]);

      final offers = results[0] as List<dynamic>;
      final popularFields = results[1] as List<FieldModel>;
      final nearbyFields = results[2] as List<FieldModel>;
      final recommendedFields = results[3] as List<FieldModel>;
      final filteredFields = results[4] as List<FieldModel>;

      final favIds = await _repository.getFavoriteFieldIds();

      emit(HomeLoaded(
        offers: offers.cast(),
        popularFields: popularFields,
        nearbyFields: nearbyFields,
        recommendedFields: recommendedFields,
        filteredFields: filteredFields,
        selectedCategory: selectedCategory,
        searchQuery: searchQuery,
        filterParams: filterParams,
        selectedCity: selectedCity,
        favoriteFieldIds: Set.from(favIds),
        isRefreshing: false,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void selectCategory(String category) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(selectedCategory: category));

      _repository.getFields(
        category: category,
        searchQuery: currentState.searchQuery,
        filterParams: currentState.filterParams,
      ).then((filtered) {
        if (state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(filteredFields: filtered));
        }
      });
    } else {
      loadHomeData();
    }
  }

  void searchFields(String query) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final updatedParams = currentState.filterParams.copyWith(searchQuery: query);
      emit(currentState.copyWith(searchQuery: query, filterParams: updatedParams));

      _repository.getFields(
        category: currentState.selectedCategory,
        searchQuery: query,
        filterParams: updatedParams,
      ).then((filtered) {
        if (state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(filteredFields: filtered));
        }
      });
    } else {
      loadHomeData();
    }
  }

  void applyFilter(FieldFilterParams params) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(filterParams: params));

      _repository.getFields(
        category: currentState.selectedCategory,
        searchQuery: currentState.searchQuery,
        filterParams: params,
      ).then((filtered) {
        if (state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(filteredFields: filtered));
        }
      });
    } else {
      loadHomeData();
    }
  }

  void selectCity(String city) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final updatedParams = currentState.filterParams.copyWith(city: city);
      emit(currentState.copyWith(selectedCity: city, filterParams: updatedParams));

      _repository.getNearbyFields(city: city).then((nearby) {
        if (state is HomeLoaded) {
          _repository.getFields(
            category: currentState.selectedCategory,
            searchQuery: currentState.searchQuery,
            filterParams: updatedParams,
          ).then((filtered) {
            if (state is HomeLoaded) {
              emit((state as HomeLoaded).copyWith(
                nearbyFields: nearby,
                filteredFields: filtered,
              ));
            }
          });
        }
      });
    } else {
      loadHomeData();
    }
  }

  Future<void> toggleFavorite(String fieldId) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final isFavNow = await _repository.toggleFavorite(fieldId);
      final favs = Set<String>.from(currentState.favoriteFieldIds);
      if (isFavNow) {
        favs.add(fieldId);
      } else {
        favs.remove(fieldId);
      }
      emit(currentState.copyWith(favoriteFieldIds: favs));
    }
  }

  void syncFavorites(Set<String> favoriteIds) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(favoriteFieldIds: Set<String>.from(favoriteIds)));
    }
  }
}
