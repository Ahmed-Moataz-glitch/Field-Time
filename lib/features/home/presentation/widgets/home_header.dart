import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/features/home/presentation/widgets/location_picker_sheet.dart';
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
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.notifications ?? 'الإشعارات'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
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
                Positioned(
                  top: 11.h,
                  right: 11.w,
                  child: Container(
                    width: 9.w,
                    height: 9.w,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
