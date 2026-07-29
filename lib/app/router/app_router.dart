import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:field_time/features/auth/presentation/screens/login_screen.dart';
import 'package:field_time/features/auth/presentation/screens/register_screen.dart';
import 'package:field_time/features/auth/presentation/screens/welcome_screen.dart';
import 'package:field_time/features/booking/presentation/screens/booking_success_screen.dart';
import 'package:field_time/features/field_details/presentation/screens/field_details_screen.dart';
import 'package:field_time/features/home/presentation/screens/main_layout_screen.dart';

abstract class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String fieldDetails = '/field-details/:id';
  static const String bookingSuccess = '/booking-success';

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: welcome,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
    routes: [
      GoRoute(
        path: welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: main,
        builder: (context, state) => const MainLayoutScreen(),
      ),
      GoRoute(
        path: fieldDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'field-1';
          return FieldDetailsScreen(fieldId: id);
        },
      ),
      GoRoute(
        path: bookingSuccess,
        builder: (context, state) => const BookingSuccessScreen(),
      ),
    ],
  );
}
