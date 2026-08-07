import 'package:field_time/features/coupons/data/repositories/coupon_repository.dart';
import 'package:field_time/features/coupons/presentation/cubit/coupon_management_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/app/theme/app_theme.dart';
import 'package:field_time/core/localization/locale_cubit.dart';
import 'package:field_time/core/localization/locale_state.dart';
import 'package:field_time/core/services/supabase_service.dart';
import 'package:field_time/core/utils/app_constants.dart';
import 'package:field_time/core/widgets/app_error_widget.dart';
import 'package:field_time/features/auth/data/repositories/auth_repository.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/booking/data/repositories/booking_repository.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:field_time/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:field_time/features/home/data/repositories/field_repository.dart';
import 'package:field_time/features/home/presentation/cubit/home_cubit.dart';
import 'package:field_time/features/notifications/data/repositories/notification_repository.dart';
import 'package:field_time/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:field_time/features/profile/presentation/cubit/profile_cubit.dart';

import 'package:field_time/core/services/firebase_service.dart';
import 'package:field_time/core/utils/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Production Global Error Handlers
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('Global FlutterError caught: ${details.exceptionAsString()}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('PlatformDispatcher error caught: $error');
    }
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return AppErrorWidget(errorDetails: details);
  };

  await SupabaseService.init();
  await FirebaseService.init();
  await setupGetIt();

  runApp(const FieldTimeApp());
}

class FieldTimeApp extends StatelessWidget {
  const FieldTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fieldRepo = FieldRepository();
    final bookingRepo = BookingRepository();
    final authRepo = AuthRepository();
    final notifRepo = NotificationRepository();
    final couponRepo = CouponRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => AuthCubit(authRepo)),
        BlocProvider(create: (_) => HomeCubit(fieldRepo)),
        BlocProvider(create: (_) => BookingCubit(repository: bookingRepo)),
        BlocProvider(create: (_) => ProfileCubit(authRepo)),
        BlocProvider(create: (_) => FavoritesCubit(fieldRepo)),
        BlocProvider(create: (_) => NotificationsCubit(notifRepo)),
        BlocProvider(create: (_) => CouponManagementCubit(couponRepo)),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp.router(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.system,
                locale: localeState.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
