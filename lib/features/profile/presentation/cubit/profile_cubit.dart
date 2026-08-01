import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/features/auth/data/models/user_model.dart';
import 'package:field_time/features/auth/data/repositories/auth_repository.dart';
import 'package:field_time/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _repository;

  ProfileCubit(this._repository) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        // Fallback default user profile if unauthenticated / offline
        emit(const ProfileLoaded(
          UserModel(
            id: 'u1',
            fullName: 'أحمد محمد',
            email: 'ahmed@fieldtime.app',
            phone: '01012345678',
            role: 'user',
            city: 'القاهرة',
            avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
          ),
        ));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String city,
  }) async {
    try {
      final updatedUser = await _repository.updateProfile(
        fullName: fullName,
        phone: phone,
        city: city,
      );
      emit(ProfileLoaded(updatedUser));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAvatar(String avatarUrl) async {
    try {
      final updatedUser = await _repository.updateAvatar(avatarUrl);
      emit(ProfileLoaded(updatedUser));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
