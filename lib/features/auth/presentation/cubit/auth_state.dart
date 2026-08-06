import 'package:equatable/equatable.dart';
import 'package:field_time/features/auth/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class SendingOtp extends AuthState {}

class OtpSent extends AuthState {
  final String message;

  const OtpSent(this.message);
}

class SendingOtpError extends AuthState {
  final String message;

  const SendingOtpError(this.message);
}

class VerifyingOtp extends AuthState {}

class OtpVerified extends AuthState {}

class VerifyingOtpError extends AuthState {
  final String message;

  const VerifyingOtpError(this.message);
}

class LoginWithGoogleLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthSuccess extends AuthState {}

class LoginWithGoogleSuccess extends AuthState {}

class LoginWithGoogleError extends AuthState {
  final String message;

  const LoginWithGoogleError(this.message);
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetSent extends AuthState {
  final String email;

  const PasswordResetSent(this.email);

  @override
  List<Object?> get props => [email];
}
