import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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

  const FavoritesLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FieldRepository _repository;

  FavoritesCubit(this._repository) : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    try {
      final fields = await _repository.getFields();
      final favs = fields.where((f) => f.isFavorite).toList();
      emit(FavoritesLoaded(favs));
    } catch (_) {
      emit(const FavoritesLoaded([]));
    }
  }
}
