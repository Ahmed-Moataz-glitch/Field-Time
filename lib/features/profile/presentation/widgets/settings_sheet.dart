import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/localization/locale_cubit.dart';
import 'package:field_time/core/localization/locale_state.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: Text(
                'الإعدادات والتفضيلات',
                style: AppTypography.heading3(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 24.h),

            // Language Setting Section
            Text(
              'لغة التطبيق (App Language)',
              style: AppTypography.caption(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, state) {
                final isArabic = state.locale.languageCode == 'ar';

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.greyLight,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => context.read<LocaleCubit>().changeLanguage('ar'),
                        leading: Icon(
                          Icons.language_rounded,
                          color: isArabic ? AppColors.primary : AppColors.iconGrey,
                          size: 22.sp,
                        ),
                        title: Text(
                          'العربية (Arabic)',
                          style: AppTypography.body(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ).copyWith(
                            fontWeight: isArabic ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isArabic
                            ? Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20.sp)
                            : null,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        onTap: () => context.read<LocaleCubit>().changeLanguage('en'),
                        leading: Icon(
                          Icons.language_rounded,
                          color: !isArabic ? AppColors.primary : AppColors.iconGrey,
                          size: 22.sp,
                        ),
                        title: Text(
                          'English (الإنجليزية)',
                          style: AppTypography.body(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ).copyWith(
                            fontWeight: !isArabic ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: !isArabic
                            ? Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20.sp)
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),

            // Notifications Setting Section
            Text(
              'الإشعارات',
              style: AppTypography.caption(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.greyLight,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: SwitchListTile(
                value: _notificationsEnabled,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                title: Text(
                  'إشعارات التذكير والعروض',
                  style: AppTypography.body(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'استلام تنبيهات بمواعيد المباريات وأحدث العروض والخصومات',
                  style: AppTypography.small(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                },
              ),
            ),
            SizedBox(height: 24.h),

            // App Version Info Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'FieldTime - حجز ملاعب كرة القدم',
                    style: AppTypography.caption(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'الإصدار 1.0.0 (Build 2026)',
                    style: AppTypography.small(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ).copyWith(fontSize: 10.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
