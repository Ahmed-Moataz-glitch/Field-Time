import 'package:field_time/core/utils/secure_storage.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:field_time/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:field_time/features/auth/presentation/screens/successful_reset_password_screen.dart';
import 'package:field_time/features/auth/presentation/screens/verify_code_screen.dart';
import 'package:field_time/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:field_time/features/owner_dashboard/presentation/screens/owner_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/features/auth/presentation/screens/login_screen.dart';
import 'package:field_time/features/auth/presentation/screens/register_screen.dart';
import 'package:field_time/features/auth/presentation/screens/welcome_screen.dart';
import 'package:field_time/features/booking/presentation/screens/booking_success_screen.dart';
import 'package:field_time/features/field_details/presentation/screens/field_details_screen.dart';
import 'package:field_time/features/home/presentation/screens/app_section.dart';

abstract class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String welcomePath = '/';
  static const String welcomeName = 'welcome';
  static const String loginPath = '/login';
  static const String fieldDetailsPath = '/field-details';
  static const String ownerDashboardPath = '/owner-dashboard';
  static const String registerPath = '/register';
  static const String forgetPasswordPath = '/forget-password';
  static const String verifyEmailPath = '/verify-email';
  static const String verifyCodePath = '/verify-code';
  static const String resetPasswordPath = '/reset-password';
  static const String successfulResetPasswordPath = '/successful-reset-password';
  static const String appSectionPath = '/app-section';
  static const String bookingSuccessPath = '/booking-success';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String forgetPasswordName = 'forget-password';
  static const String verifyEmailName = 'verify-email';
  static const String verifyCodeName = 'verify-code';
  static const String resetPasswordName = 'reset-password';
  static const String successfulResetPasswordName = 'successful-reset-password';
  static const String appSectionName = 'app-section';
  static const String fieldDetailsName = 'field-details';
  static const String bookingSuccessName = 'booking-success';
  static const String ownerDashboardName = 'owner-dashboard';
  static late final GoRouter router;

  static Future<void> initializeRouter() async {
    router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: await initScreen(),
      debugLogDiagnostics: true,
      errorBuilder: (context, state) =>
          Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
      routes: [
        GoRoute(
          path: welcomePath,
          name: welcomeName,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: loginPath,
          name: loginName,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: registerPath,
          name: registerName,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: forgetPasswordPath,
          name: forgetPasswordName,
          builder: (context, state) {
            final authCubit =
                state.extra! as AuthCubit;
            return ForgetPasswordScreen(authCubit: authCubit);
          },
        ),
        GoRoute(
          path: verifyEmailPath,
          name: verifyEmailName,
          builder: (context, state) {
            final authCubit =
                state.extra! as AuthCubit;
            final email = state.uri.queryParameters['email'];
            return VerifyEmailScreen(authCubit: authCubit, email: email);
          },
        ),
        GoRoute(
          path: verifyCodePath,
          name: verifyCodeName,
          builder: (context, state) {
            final authCubit =
                state.extra! as AuthCubit;
            final email = state.uri.queryParameters['email'];
            return VerifyCodeScreen(authCubit: authCubit, email: email);
          },
        ),
        GoRoute(
          path: resetPasswordPath,
          name: resetPasswordName,
          builder: (context, state) {
            final authCubit =
                state.extra! as AuthCubit;
            return ResetPasswordScreen(authCubit: authCubit);
          },
        ),
        GoRoute(
          path: successfulResetPasswordPath,
          name: successfulResetPasswordName,
          builder: (context, state) => const SuccessfulResetPasswordScreen(),
        ),
        GoRoute(
          path: ownerDashboardPath,
          name: ownerDashboardName,
          builder: (context, state) => const OwnerDashboardScreen(),
        ),
        GoRoute(
          path: appSectionPath,
          name: appSectionName,
          builder: (context, state) => const AppSection(),
        ),
        GoRoute(
          path: fieldDetailsPath,
          name: fieldDetailsName,
          builder: (context, state) {
            final fieldId = state.uri.queryParameters['fieldId'];
            return FieldDetailsScreen(fieldId: fieldId!);
          },
        ),
        GoRoute(
          path: bookingSuccessPath,
          name: bookingSuccessName,
          builder: (context, state) => const BookingSuccessScreen(),
        ),
      ],
    );
  }

  static Future<String> initScreen() async {
    final token = await SecureStorage.getToken();
    return token != null ? appSectionPath : welcomePath;
  }
}
