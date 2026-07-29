import 'package:go_router/go_router.dart';
import 'package:field_time/features/auth/presentation/screens/login_screen.dart';
import 'package:field_time/features/auth/presentation/screens/register_screen.dart';
import 'package:field_time/features/auth/presentation/screens/welcome_screen.dart';
import 'package:field_time/features/booking/presentation/screens/booking_success_screen.dart';
import 'package:field_time/features/field_details/presentation/screens/field_details_screen.dart';
import 'package:field_time/features/home/presentation/screens/main_layout_screen.dart';

abstract class AppRouter {
  static final router = GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainLayoutScreen(),
      ),
      GoRoute(
        path: '/field-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'field-1';
          return FieldDetailsScreen(fieldId: id);
        },
      ),
      GoRoute(
        path: '/booking-success',
        builder: (context, state) => const BookingSuccessScreen(),
      ),
    ],
  );
}
