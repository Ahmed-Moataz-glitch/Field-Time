import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/core/errors/failures.dart';
import 'package:field_time/features/auth/data/repositories/auth_repository.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  /// Check current active user session on app launch
  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  /// Sign in with email and password
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _repository.login(email: email, password: password);
      emit(Authenticated(user));
    } on Failure catch (failure) {
      emit(AuthError(failure.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Register new user account with profile parameters
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String role = 'user',
    String city = 'القاهرة',
  }) async {
    emit(AuthLoading());
    try {
      final user = await _repository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
        city: city,
      );
      emit(Authenticated(user));
    } on Failure catch (failure) {
      emit(AuthError(failure.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Reset password request
  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _repository.resetPassword(email);
      emit(PasswordResetSent(email));
    } on Failure catch (failure) {
      emit(AuthError(failure.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Sign out
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}
    emit(Unauthenticated());
  }

  /// Guest access mode
  void continueAsGuest() {
    emit(Unauthenticated());
  }
}
