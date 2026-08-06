import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/widgets/custom_text_field.dart';
import 'package:field_time/features/home/data/models/field_filter_params.dart';
import 'package:field_time/features/home/presentation/widgets/filter_bottom_sheet.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FieldFilterParams filterParams;
  final ValueChanged<FieldFilterParams> onFilterApplied;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.filterParams,
    required this.onFilterApplied,
  });

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentParams: filterParams,
        onApply: onFilterApplied,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final hasActiveFilters = filterParams.hasActiveFilters;

    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: controller,
            hintText: l10n?.searchHint ?? 'ابحث عن ملعب أو منطقة',
            prefixIcon: const Icon(Icons.search, color: AppColors.iconGrey),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.iconGrey),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 12.w),
        // Filter Button
        GestureDetector(
          onTap: () => _openFilterSheet(context),
          child: Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: hasActiveFilters
                  ? AppColors.primary
                  : (isDark ? AppColors.cardDark : AppColors.cardLight),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: hasActiveFilters
                    ? AppColors.primary
                    : (isDark ? Colors.white10 : AppColors.greyBorder),
              ),
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
                  Icons.tune_rounded,
                  color: hasActiveFilters
                      ? Colors.white
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  size: 22.sp,
                ),
                if (hasActiveFilters)
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
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
