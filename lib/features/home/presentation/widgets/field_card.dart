import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/rating_badge.dart';
import 'package:field_time/features/home/data/models/field_model.dart';
import 'package:field_time/l10n/app_localizations.dart';

class FieldCard extends StatelessWidget {
  final FieldModel field;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const FieldCard({
    super.key,
    required this.field,
    this.isFavorite = false,
    required this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail with image & rating
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl: field.mainImage,
                    width: 115.w,
                    height: 115.h,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 115.w,
                      height: 115.h,
                      color: isDark ? AppColors.backgroundDark : AppColors.greyLight,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 115.w,
                      height: 115.h,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.sports_soccer, color: AppColors.primary),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8.h,
                  right: 8.w,
                  child: RatingBadge(rating: field.rating),
                ),
                if (field.isAvailableToday)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        l10n?.availableBadge ?? 'متاح اليوم',
                        style: AppTypography.small(color: Colors.white).copyWith(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 14.w),
            // Information Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          field.name,
                          style: AppTypography.title(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onFavoriteToggle != null)
                        GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? AppColors.error : AppColors.iconGrey,
                            size: 20.sp,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          field.address.isNotEmpty ? field.address : '${field.city} - ${field.area}',
                          style: AppTypography.caption(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Tags Row (Grass & Field Type)
                  Wrap(
                    spacing: 6.w,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.backgroundDark : AppColors.greyLight,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          field.fieldType,
                          style: AppTypography.small(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ).copyWith(fontSize: 10.sp),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.backgroundDark : AppColors.greyLight,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          field.grassType,
                          style: AppTypography.small(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ).copyWith(fontSize: 10.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Price and Distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${field.pricePerHour.toInt()} ج.م',
                            style: AppTypography.body(color: AppColors.primary).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (field.oldPrice != null) ...[
                            SizedBox(width: 6.w),
                            Text(
                              '${field.oldPrice!.toInt()}',
                              style: AppTypography.small(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ).copyWith(decoration: TextDecoration.lineThrough),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.near_me_outlined,
                            size: 13.sp,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            field.distance,
                            style: AppTypography.small(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
