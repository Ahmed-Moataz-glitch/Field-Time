import 'package:field_time/core/utils/secure_storage.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:field_time/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:field_time/features/auth/presentation/screens/successful_reset_password_screen.dart';
import 'package:field_time/features/auth/presentation/screens/verify_code_screen.dart';
import 'package:field_time/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:field_time/features/booking/presentation/screens/booking_screen.dart';
import 'package:field_time/features/coupons/presentation/screens/create_coupon_screen.dart';
import 'package:field_time/features/coupons/presentation/screens/manage_coupons_screen.dart';
import 'package:field_time/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:field_time/features/owner_dashboard/presentation/cubit/owner_dashboard_cubit.dart';
import 'package:field_time/features/owner_dashboard/presentation/screens/add_edit_field_screen.dart';
import 'package:field_time/features/owner_dashboard/presentation/screens/owner_bookings_screen.dart';
import 'package:field_time/features/owner_dashboard/presentation/screens/owner_dashboard_screen.dart';
import 'package:field_time/features/owner_dashboard/presentation/screens/owner_statistics_screen.dart';
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
  static const String bookingPath = '/booking';
  static const String bookingName = 'booking';
  static const String addFieldPath = '/add-field';
  static const String addFieldName = 'add-field';
  static const String editFieldPath = '/edit-field';
  static const String editFieldName = 'edit-field';
  static const String ownerBookingsPath = '/owner-bookings';
  static const String ownerBookingsName = 'owner-bookings';
  static const String manageCouponsPath = '/manage-coupons';
  static const String manageCouponsName = 'manage-coupons';
  static const String ownerStatsPath = '/owner-stats';
  static const String ownerStatsName = 'owner-stats';
  static const String createCouponPath = '/create-coupon';
  static const String createCouponName = 'create-coupon';
  static const String fieldDetailsPath = '/field-details';
  static const String notificationsPath = '/notifications';
  static const String notificationsName = 'notifications';
  static const String ownerDashboardPath = '/owner-dashboard';
  static const String registerPath = '/register';
  static const String forgetPasswordPath = '/forget-password';
  static const String verifyEmailPath = '/verify-email';
  static const String verifyCodePath = '/verify-code';
  static const String resetPasswordPath = '/reset-password';
  static const String successfulResetPasswordPath =
      '/successful-reset-password';
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
          path: createCouponPath,
          name: createCouponName,
          builder: (context, state) => const CreateCouponScreen(),
        ),
        GoRoute(
          path: registerPath,
          name: registerName,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: addFieldPath,
          name: addFieldName,
          builder: (context, state) {
            final ownerDashboardCubit = state.extra as OwnerDashboardCubit?;
            return AddEditFieldScreen(ownerDashboardCubit: ownerDashboardCubit);
          },
        ),
        GoRoute(
          path: editFieldPath,
          name: editFieldName,
          builder: (context, state) {
            final ownerDashboardCubit = state.extra as OwnerDashboardCubit?;
            final fieldId = state.uri.queryParameters['fieldId'];
            return AddEditFieldScreen(
              ownerDashboardCubit: ownerDashboardCubit,
              fieldId: fieldId,
            );
          },
        ),
        GoRoute(
          path: ownerBookingsPath,
          name: ownerBookingsName,
          builder: (context, state) {
            final ownerDashboardCubit = state.extra as OwnerDashboardCubit?;
            return OwnerBookingsScreen(
              ownerDashboardCubit: ownerDashboardCubit,
            );
          },
        ),
        GoRoute(
          path: manageCouponsPath,
          name: manageCouponsName,
          builder: (context, state) => const ManageCouponsScreen(),
        ),
        GoRoute(
          path: ownerStatsPath,
          name: ownerStatsName,
          builder: (context, state) {
            final ownerDashboardCubit = state.extra as OwnerDashboardCubit?;
            return OwnerStatisticsScreen(
              ownerDashboardCubit: ownerDashboardCubit,
            );
          },
        ),
        GoRoute(
          path: forgetPasswordPath,
          name: forgetPasswordName,
          builder: (context, state) {
            final authCubit = state.extra as AuthCubit?;
            return ForgetPasswordScreen(authCubit: authCubit);
          },
        ),
        GoRoute(
          path: verifyEmailPath,
          name: verifyEmailName,
          builder: (context, state) {
            final authCubit = state.extra as AuthCubit?;
            final email = state.uri.queryParameters['email'];
            return VerifyEmailScreen(authCubit: authCubit, email: email);
          },
        ),
        GoRoute(
          path: verifyCodePath,
          name: verifyCodeName,
          builder: (context, state) {
            final authCubit = state.extra as AuthCubit?;
            final email = state.uri.queryParameters['email'];
            return VerifyCodeScreen(authCubit: authCubit, email: email);
          },
        ),
        GoRoute(
          path: resetPasswordPath,
          name: resetPasswordName,
          builder: (context, state) {
            final authCubit = state.extra as AuthCubit?;
            return ResetPasswordScreen(authCubit: authCubit);
          },
        ),
        GoRoute(
          path: bookingPath,
          name: bookingName,
          builder: (context, state) {
            Map<String, dynamic>? extraMap;
            if (state.extra is Map<String, dynamic>) {
              extraMap = state.extra as Map<String, dynamic>;
            }

            final fieldId =
                extraMap?['fieldId']?.toString() ??
                state.uri.queryParameters['fieldId'] ??
                'field-1';
            final fieldName =
                extraMap?['fieldName']?.toString() ??
                state.uri.queryParameters['fieldName'] ??
                'ملعب كرة قدم';
            final fieldAddress =
                extraMap?['fieldAddress']?.toString() ??
                state.uri.queryParameters['fieldAddress'] ??
                'القاهرة';
            final fieldImage =
                extraMap?['fieldImage']?.toString() ??
                state.uri.queryParameters['fieldImage'] ??
                '';
            final priceVal =
                extraMap?['price'] ?? state.uri.queryParameters['price'];
            final price = (priceVal is num)
                ? priceVal.toDouble()
                : double.tryParse(priceVal?.toString() ?? '350') ?? 350.0;
            final initialDate =
                extraMap?['initialDate']?.toString() ??
                state.uri.queryParameters['initialDate'];
            final initialTimeSlot =
                extraMap?['initialTimeSlot']?.toString() ??
                state.uri.queryParameters['initialTimeSlot'];
            final initialCouponCode =
                extraMap?['initialCouponCode']?.toString() ??
                extraMap?['couponCode']?.toString() ??
                state.uri.queryParameters['initialCouponCode'] ??
                state.uri.queryParameters['couponCode'];

            return BookingScreen(
              fieldId: fieldId,
              fieldName: fieldName,
              fieldAddress: fieldAddress,
              fieldImage: fieldImage,
              price: price,
              initialDate: initialDate,
              initialTimeSlot: initialTimeSlot,
              initialCouponCode: initialCouponCode,
            );
          },
        ),
        GoRoute(
          path: notificationsPath,
          name: notificationsName,
          builder: (context, state) => const NotificationsScreen(),
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
          builder: (context, state) {
            final initialIndex = state.extra ?? 0;
            return AppSection(initialIndex: initialIndex as int);
          },
        ),
        GoRoute(
          path: fieldDetailsPath,
          name: fieldDetailsName,
          builder: (context, state) {
            final fieldId = state.uri.queryParameters['fieldId'] ?? 'field-1';
            return FieldDetailsScreen(fieldId: fieldId);
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
