import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/features/home/data/models/field_model.dart';
import 'package:field_time/features/home/data/repositories/field_repository.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<FieldModel> favorites;
  final List<FieldModel> filteredFavorites;
  final Set<String> favoriteIds;
  final String searchQuery;
  final FieldModel? lastRemovedField;

  const FavoritesLoaded({
    required this.favorites,
    required this.filteredFavorites,
    required this.favoriteIds,
    this.searchQuery = '',
    this.lastRemovedField,
  });

  FavoritesLoaded copyWith({
    List<FieldModel>? favorites,
    List<FieldModel>? filteredFavorites,
    Set<String>? favoriteIds,
    String? searchQuery,
    FieldModel? lastRemovedField,
    bool clearLastRemoved = false,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      filteredFavorites: filteredFavorites ?? this.filteredFavorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      searchQuery: searchQuery ?? this.searchQuery,
      lastRemovedField: clearLastRemoved ? null : (lastRemovedField ?? this.lastRemovedField),
    );
  }

  @override
  List<Object?> get props => [
        favorites,
        filteredFavorites,
        favoriteIds,
        searchQuery,
        lastRemovedField,
      ];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FieldRepository _repository;

  FavoritesCubit(this._repository) : super(FavoritesInitial());

  Future<void> loadFavorites({bool isRefresh = false}) async {
    final currentState = state;
    if (!isRefresh && currentState is! FavoritesLoaded) {
      emit(FavoritesLoading());
    }

    try {
      final favFields = await _repository.getFavoriteFields();
      final favIds = favFields.map((f) => f.id).toSet();
      final query = currentState is FavoritesLoaded ? currentState.searchQuery : '';

      final filtered = _filterList(favFields, query);

      emit(FavoritesLoaded(
        favorites: favFields,
        filteredFavorites: filtered,
        favoriteIds: favIds,
        searchQuery: query,
      ));
    } catch (e) {
      emit(FavoritesError('فشل تحميل المفضلة: ${e.toString()}'));
    }
  }

  Future<void> toggleFavorite(FieldModel field) async {
    try {
      await _repository.toggleFavorite(field.id);
      await loadFavorites(isRefresh: true);
    } catch (_) {}
  }

  Future<void> removeFavorite(FieldModel field) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      final updatedList = currentState.favorites.where((f) => f.id != field.id).toList();
      final updatedIds = Set<String>.from(currentState.favoriteIds)..remove(field.id);
      final updatedFiltered = _filterList(updatedList, currentState.searchQuery);

      emit(currentState.copyWith(
        favorites: updatedList,
        filteredFavorites: updatedFiltered,
        favoriteIds: updatedIds,
        lastRemovedField: field,
      ));

      try {
        await _repository.toggleFavorite(field.id);
      } catch (_) {}
    }
  }

  Future<void> undoRemoveFavorite() async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      final fieldToRestore = currentState.lastRemovedField;

      if (fieldToRestore != null) {
        final updatedList = [fieldToRestore, ...currentState.favorites];
        final updatedIds = Set<String>.from(currentState.favoriteIds)..add(fieldToRestore.id);
        final updatedFiltered = _filterList(updatedList, currentState.searchQuery);

        emit(currentState.copyWith(
          favorites: updatedList,
          filteredFavorites: updatedFiltered,
          favoriteIds: updatedIds,
          clearLastRemoved: true,
        ));

        try {
          await _repository.toggleFavorite(fieldToRestore.id);
        } catch (_) {}
      }
    }
  }

  void searchFavorites(String query) {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      final filtered = _filterList(currentState.favorites, query);
      emit(currentState.copyWith(
        searchQuery: query,
        filteredFavorites: filtered,
      ));
    }
  }

  List<FieldModel> _filterList(List<FieldModel> fields, String query) {
    if (query.trim().isEmpty) return fields;
    final q = query.trim().toLowerCase();
    return fields.where((f) {
      return f.name.toLowerCase().contains(q) ||
          f.city.toLowerCase().contains(q) ||
          f.area.toLowerCase().contains(q) ||
          f.address.toLowerCase().contains(q);
    }).toList();
  }
}
