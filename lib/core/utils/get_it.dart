import 'package:field_time/core/localization/locale_cubit.dart';
import 'package:field_time/features/auth/data/repositories/auth_repository.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/booking/data/repositories/booking_repository.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:field_time/features/coupons/data/repositories/coupon_repository.dart';
import 'package:field_time/features/coupons/presentation/cubit/coupon_management_cubit.dart';
import 'package:field_time/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:field_time/features/field_details/presentation/cubit/field_details_cubit.dart';
import 'package:field_time/features/home/data/repositories/field_repository.dart';
import 'package:field_time/features/home/presentation/cubit/home_cubit.dart';
import 'package:field_time/features/notifications/data/repositories/notification_repository.dart';
import 'package:field_time/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:field_time/features/owner_dashboard/data/repositories/owner_repository.dart';
import 'package:field_time/features/owner_dashboard/presentation/cubit/owner_dashboard_cubit.dart';
import 'package:field_time/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:field_time/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  getIt.registerFactory<LocaleCubit>(
    () => LocaleCubit(),
  );

  getIt.registerSingleton<AuthRepository>(AuthRepository());
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      getIt<AuthRepository>(),
    ),
  );

  getIt.registerSingleton<CouponRepository>(CouponRepository());
  getIt.registerFactory<CouponManagementCubit>(
    () => CouponManagementCubit(
      getIt<CouponRepository>(),
    ),
  );

  getIt.registerSingleton<NotificationRepository>(NotificationRepository());
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      getIt<NotificationRepository>(),
    ),
  );

  getIt.registerSingleton<OwnerRepository>(OwnerRepository());
  getIt.registerFactory<OwnerDashboardCubit>(
    () => OwnerDashboardCubit(
      getIt<OwnerRepository>(),
    ),
  );

  getIt.registerSingleton<FieldRepository>(FieldRepository());
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      getIt<FieldRepository>(),
    ),
  );

  getIt.registerFactory<FieldDetailsCubit>(
    () => FieldDetailsCubit(
      getIt<FieldRepository>(),
    ),
  );

  getIt.registerFactory<ReviewsCubit>(
    () => ReviewsCubit(
      getIt<FieldRepository>(),
    ),
  );

  getIt.registerSingleton<BookingRepository>(BookingRepository());
  getIt.registerFactory<BookingCubit>(
    () => BookingCubit(
      repository: getIt<BookingRepository>(),
    ),
  );

  getIt.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(
      getIt<FieldRepository>(),
    ),
  );

  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getIt<AuthRepository>(),
    ),
  );
}
