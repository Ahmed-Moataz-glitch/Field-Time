import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:field_time/features/auth/presentation/screens/login_screen.dart';
import 'package:field_time/features/auth/presentation/screens/register_screen.dart';
import 'package:field_time/features/auth/presentation/screens/welcome_screen.dart';
import 'package:field_time/features/booking/presentation/screens/booking_screen.dart';
import 'package:field_time/features/booking/presentation/screens/booking_success_screen.dart';
import 'package:field_time/features/field_details/presentation/screens/field_details_screen.dart';
import 'package:field_time/features/home/presentation/screens/main_layout_screen.dart';
import 'package:field_time/features/owner_dashboard/presentation/screens/add_edit_field_screen.dart';
import 'package:field_time/features/owner_dashboard/presentation/screens/owner_bookings_screen.dart';
import 'package:field_time/features/owner_dashboard/presentation/screens/owner_dashboard_screen.dart';
import 'package:field_time/features/owner_dashboard/presentation/screens/owner_statistics_screen.dart';
import 'package:field_time/features/coupons/presentation/screens/create_coupon_screen.dart';
import 'package:field_time/features/coupons/presentation/screens/manage_coupons_screen.dart';
import 'package:field_time/features/notifications/presentation/screens/notifications_screen.dart';

abstract class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String fieldDetails = '/field-details/:id';
  static const String booking = '/booking';
  static const String bookingSuccess = '/booking-success';
  static const String notifications = '/notifications';
  static const String ownerDashboard = '/owner-dashboard';
  static const String addField = '/add-field';
  static const String editField = '/edit-field/:id';
  static const String ownerBookings = '/owner-bookings';
  static const String ownerStats = '/owner-stats';
  static const String manageCoupons = '/manage-coupons';
  static const String createCoupon = '/create-coupon';

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
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final initialIndex = extra?['initialIndex'] as int? ?? 0;
          return MainLayoutScreen(initialIndex: initialIndex);
        },
      ),
      GoRoute(
        path: fieldDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'field-1';
          return FieldDetailsScreen(fieldId: id);
        },
      ),
      GoRoute(
        path: booking,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BookingScreen(
            fieldId: extra['fieldId'] as String? ?? 'field-1',
            fieldName: extra['fieldName'] as String? ?? 'أرينا سبورت (Arena Sport)',
            fieldAddress: extra['fieldAddress'] as String? ?? 'مدينة نصر - شارع الطيران',
            fieldImage: extra['fieldImage'] as String? ?? 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
            price: (extra['price'] as num?)?.toDouble() ?? 350.0,
            initialDate: extra['initialDate'] as String?,
            initialTimeSlot: extra['initialTimeSlot'] as String?,
          );
        },
      ),
      GoRoute(
        path: bookingSuccess,
        builder: (context, state) => const BookingSuccessScreen(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: ownerDashboard,
        builder: (context, state) => const OwnerDashboardScreen(),
      ),
      GoRoute(
        path: addField,
        builder: (context, state) => const AddEditFieldScreen(),
      ),
      GoRoute(
        path: editField,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return AddEditFieldScreen(fieldId: id);
        },
      ),
      GoRoute(
        path: ownerBookings,
        builder: (context, state) => const OwnerBookingsScreen(),
      ),
      GoRoute(
        path: ownerStats,
        builder: (context, state) => const OwnerStatisticsScreen(),
      ),
      GoRoute(
        path: manageCoupons,
        builder: (context, state) => const ManageCouponsScreen(),
      ),
      GoRoute(
        path: createCoupon,
        builder: (context, state) => const CreateCouponScreen(),
      ),
    ],
  );
}
