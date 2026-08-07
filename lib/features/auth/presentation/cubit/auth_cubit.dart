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
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _repository.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(Authenticated(user));
    } on Failure catch (failure) {
      emit(AuthError(failure.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(LoginWithGoogleLoading());
    try {
      final success = await _repository.loginWithGoogle();
      if (success) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          emit(LoginWithGoogleSuccess());
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(LoginWithGoogleError('فشل تسجيل الدخول باستخدام Google'));
      }
    } on Failure catch (failure) {
      emit(LoginWithGoogleError(failure.message));
    } catch (e) {
      emit(LoginWithGoogleError(e.toString()));
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

  Future<void> sendOtpForNewUser(String email) async {
    emit(SendingOtp());
    try {
      await _repository.sendOtpForNewUser(email);
      emit(OtpSent('OTP sent successfully'));
    } catch (e) {
      emit(SendingOtpError(e.toString()));
    }
  }

  Future<void> sendOtpForExistingUser(String email) async {
    emit(SendingOtp());
    try {
      await _repository.sendOtpForExistingUser(email);
      emit(OtpSent('OTP sent successfully'));
    } catch (e) {
      emit(SendingOtpError(e.toString()));
    }
  }

  Future<void> validateOtp({required String email, required String otp}) async {
    try {
      final result = await _repository.validateOtp(email: email, otp: otp);
      switch (result) {
        case true:
          emit(OtpVerified());
        case false:
          emit(VerifyingOtpError('Invalid OTP'));
      }
    } catch (e) {
      emit(VerifyingOtpError(e.toString()));
    }
  }

  /// Reset password request
  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _repository.resetPassword(email);
      emit(AuthSuccess());
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
