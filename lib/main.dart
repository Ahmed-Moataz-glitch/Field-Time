import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/app/theme/app_theme.dart';
import 'package:field_time/core/utils/app_constants.dart';
import 'package:field_time/features/auth/data/repositories/auth_repository.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/booking/data/repositories/booking_repository.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:field_time/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:field_time/features/home/data/repositories/field_repository.dart';
import 'package:field_time/features/home/presentation/cubit/home_cubit.dart';
import 'package:field_time/features/profile/presentation/cubit/profile_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseProjectUrl,
      publishableKey: AppConstants.supabaseProjectPublishableKey,
    );
  } catch (_) {}

  runApp(const FieldTimeApp());
}

class FieldTimeApp extends StatelessWidget {
  const FieldTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fieldRepo = FieldRepository();
    final bookingRepo = BookingRepository();
    final authRepo = AuthRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authRepo)),
        BlocProvider(create: (_) => HomeCubit(fieldRepo)),
        BlocProvider(create: (_) => BookingCubit(bookingRepo)),
        BlocProvider(create: (_) => ProfileCubit(authRepo)),
        BlocProvider(create: (_) => FavoritesCubit(fieldRepo)),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routerConfig: AppRouter.router,
            builder: (context, widget) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: widget ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
