import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/features/home/presentation/widgets/location_picker_sheet.dart';
import 'package:field_time/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String selectedCity;
  final ValueChanged<String> onCityChanged;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.selectedCity,
    required this.onCityChanged,
  });

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPickerSheet(
        selectedCity: selectedCity,
        onCitySelected: onCityChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Greeting & Location Selector
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${l10n?.greetingUser ?? 'مرحباً'} ',
                    style: AppTypography.caption(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '$userName 👋',
                      style: AppTypography.title(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ).copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: () => _showLocationPicker(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      selectedCity.isNotEmpty ? selectedCity : (l10n?.cairo ?? 'القاهرة'),
                      style: AppTypography.body(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),

        // Notifications Bell Icon
        BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            final unreadCount = state is NotificationsLoaded ? state.unreadCount : 0;

            return Semantics(
              button: true,
              label: 'الإشعارات',
              hint: unreadCount > 0 ? 'لديك $unreadCount إشعارات غير مقروءة' : 'فتح الإشعارات',
              child: Tooltip(
                message: 'الإشعارات',
                child: GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.greyLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          size: 24.sp,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: 9.h,
                            right: 9.w,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              constraints: BoxConstraints(minWidth: 14.w, minHeight: 14.w),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$unreadCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
