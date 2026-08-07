import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class LocationPickerSheet extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onCitySelected;

  const LocationPickerSheet({
    super.key,
    required this.selectedCity,
    required this.onCitySelected,
  });

  static const List<Map<String, String>> _cities = [
    {'nameAr': 'جميع المدن', 'nameEn': 'All Cities', 'icon': '🌆'},
    {'nameAr': 'القاهرة', 'nameEn': 'Cairo', 'icon': '🏙️'},
    {'nameAr': 'الجيزة', 'nameEn': 'Giza', 'icon': '🏛️'},
    {'nameAr': 'الإسكندرية', 'nameEn': 'Alexandria', 'icon': '🌊'},
    {'nameAr': '6 أكتوبر', 'nameEn': '6th of October', 'icon': '🏘️'},
    {'nameAr': 'التجمع الخامس', 'nameEn': '5th Settlement', 'icon': '🏙️'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            l10n?.selectLocation ?? 'اختر المدينة / المنطقة',
            style: AppTypography.title(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cities.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: isDark ? Colors.white10 : AppColors.divider,
            ),
            itemBuilder: (context, index) {
              final city = _cities[index];
              final cityName = isAr ? city['nameAr']! : city['nameEn']!;
              final isSelected = cityName == selectedCity ||
                  (selectedCity.isEmpty && cityName == (isAr ? 'جميع المدن' : 'All Cities'));

              return ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                leading: Text(
                  city['icon']!,
                  style: TextStyle(fontSize: 22.sp),
                ),
                title: Text(
                  cityName,
                  style: AppTypography.body(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22.sp)
                    : null,
                onTap: () {
                  onCitySelected(cityName);
                  Navigator.pop(context);
                },
              );
            },
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
