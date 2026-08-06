import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/core/widgets/secondary_outlined_button.dart';
import 'package:field_time/features/home/data/models/field_filter_params.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class FilterBottomSheet extends StatefulWidget {
  final FieldFilterParams currentParams;
  final ValueChanged<FieldFilterParams> onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentParams,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _selectedFieldType;
  late String? _selectedGrassType;
  late double _maxPrice;
  late double _minRating;
  late bool _isIndoor;
  late bool _isAvailableToday;

  @override
  void initState() {
    super.initState();
    _selectedFieldType = widget.currentParams.fieldType;
    _selectedGrassType = widget.currentParams.grassType;
    _maxPrice = widget.currentParams.maxPrice ?? 1000.0;
    _minRating = widget.currentParams.minRating ?? 0.0;
    _isIndoor = widget.currentParams.isIndoor ?? false;
    _isAvailableToday = widget.currentParams.isAvailableToday ?? false;
  }

  void _reset() {
    setState(() {
      _selectedFieldType = null;
      _selectedGrassType = null;
      _maxPrice = 1000.0;
      _minRating = 0.0;
      _isIndoor = false;
      _isAvailableToday = false;
    });
  }

  void _apply() {
    final params = FieldFilterParams(
      city: widget.currentParams.city,
      searchQuery: widget.currentParams.searchQuery,
      fieldType: _selectedFieldType,
      grassType: _selectedGrassType,
      maxPrice: _maxPrice == 1000.0 ? null : _maxPrice,
      minRating: _minRating == 0.0 ? null : _minRating,
      isIndoor: _isIndoor ? true : null,
      isAvailableToday: _isAvailableToday ? true : null,
    );
    widget.onApply(params);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      height: 0.85.sh,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
          SizedBox(height: 16.h),
          // Title & Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.filterTitle ?? 'تصفية البحث',
                style: AppTypography.heading3(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _reset,
                child: Text(
                  l10n?.resetFilters ?? 'إعادة ضبط',
                  style: AppTypography.body(color: AppColors.error).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Max Price Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n?.priceRange ?? 'نطاق السعر (جنيه / ساعة)',
                        style: AppTypography.title(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ).copyWith(fontWeight: FontWeight.w600, fontSize: 16.sp),
                      ),
                      Text(
                        'حتى ${_maxPrice.toInt()} ج.م',
                        style: AppTypography.body(color: AppColors.primary).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _maxPrice,
                    min: 100.0,
                    max: 1000.0,
                    divisions: 18,
                    activeColor: AppColors.primary,
                    inactiveColor: isDark ? Colors.white12 : AppColors.greyLight,
                    label: '${_maxPrice.toInt()} ج.م',
                    onChanged: (val) => setState(() => _maxPrice = val),
                  ),
                  SizedBox(height: 20.h),
                  // Field Type
                  Text(
                    l10n?.fieldType ?? 'نوع الملعب',
                    style: AppTypography.title(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 16.sp),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 10.w,
                    children: ['خماسي', 'سباعي', '11v11'].map((type) {
                      final isSelected = _selectedFieldType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.greyLight,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          fontFamily: 'Cairo',
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedFieldType = selected ? type : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),
                  // Grass Type
                  Text(
                    l10n?.grassType ?? 'نوع العشب',
                    style: AppTypography.title(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 16.sp),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 10.w,
                    children: ['عشب صناعي', 'عشب طبيعي', 'ترتان'].map((grass) {
                      final isSelected = _selectedGrassType == grass;
                      return ChoiceChip(
                        label: Text(grass),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.greyLight,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          fontFamily: 'Cairo',
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedGrassType = selected ? grass : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),
                  // Minimum Rating Filter
                  Text(
                    l10n?.minRating ?? 'الحد الأدنى للتقييم',
                    style: AppTypography.title(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 16.sp),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 10.w,
                    children: [4.0, 4.5, 4.8].map((rating) {
                      final isSelected = _minRating == rating;
                      return ChoiceChip(
                        avatar: Icon(
                          Icons.star_rounded,
                          size: 16.sp,
                          color: isSelected ? AppColors.accent : Colors.amber,
                        ),
                        label: Text('$rating+'),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.greyLight,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          fontFamily: 'Cairo',
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _minRating = selected ? rating : 0.0;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),
                  // Toggles (Indoor / Available Today)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n?.indoorOnly ?? 'مغطى (صالة مغلقة)',
                      style: AppTypography.body(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    value: _isIndoor,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isIndoor = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n?.availableToday ?? 'متاح اليوم فقط',
                      style: AppTypography.body(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    value: _isAvailableToday,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isAvailableToday = val),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SecondaryOutlinedButton(
                  title: l10n?.resetFilters ?? 'إعادة ضبط',
                  onPressed: _reset,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryButton(
                  title: l10n?.applyFilters ?? 'تطبيق الفلترة',
                  onPressed: _apply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
