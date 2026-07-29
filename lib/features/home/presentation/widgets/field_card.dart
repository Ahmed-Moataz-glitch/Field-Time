import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/rating_badge.dart';
import 'package:field_time/features/home/data/models/field_model.dart';

class FieldCard extends StatelessWidget {
  final FieldModel field;
  final VoidCallback onTap;

  const FieldCard({
    super.key,
    required this.field,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Field Thumbnail Image with Rating Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl: field.mainImage,
                    width: 110.w,
                    height: 110.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 110.w,
                      height: 110.h,
                      color: isDark ? AppColors.backgroundDark : AppColors.greyLight,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 110.w,
                      height: 110.h,
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
              ],
            ),
            SizedBox(width: 16.w),
            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.name,
                    style: AppTypography.title(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    field.area,
                    style: AppTypography.caption(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Row(
                        children: [
                          Text(
                            '${field.pricePerHour.toInt()} جنيه',
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
                      // Distance
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.sp,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          SizedBox(width: 2.w),
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
