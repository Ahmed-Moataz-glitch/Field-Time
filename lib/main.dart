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
  await SupabaseService.init();

  runApp(const FieldTimeApp());
}

class FieldTimeApp extends StatelessWidget {
  const FieldTimeApp({super.key});

  @override
  State<FieldTimeApp> createState() => _FieldTimeAppState();
}
class _FieldTimeAppState extends State<FieldTimeApp> {
  late final LocaleCubit _localeCubit;
  late final AuthCubit _authCubit;
  late final HomeCubit _homeCubit;
  late final FieldDetailsCubit _fieldDetailsCubit;
  late final BookingCubit _bookingCubit;
  late final FavoritesCubit _favoritesCubit;
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _localeCubit = getIt<LocaleCubit>();
    _authCubit = getIt<AuthCubit>();
    _homeCubit = getIt<HomeCubit>();
    _fieldDetailsCubit = getIt<FieldDetailsCubit>();
    _bookingCubit = getIt<BookingCubit>();
    _favoritesCubit = getIt<FavoritesCubit>();
    _profileCubit = getIt<ProfileCubit>();
  }

  @override
  void dispose() {
    _localeCubit.close();
    _authCubit.close();
    _homeCubit.close();
    _fieldDetailsCubit.close();
    _bookingCubit.close();
    _favoritesCubit.close();
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fieldRepo = FieldRepository();
    final bookingRepo = BookingRepository();
    final authRepo = AuthRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
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
