import 'package:field_time/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_typography.dart';

class SecondaryOutlinedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;
  final String? icon;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryOutlinedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: width ?? size.width,
      height: height ?? 52.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: borderColor ?? AppColors.primary.withValues(alpha: 0.8),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.r),
          ),
        ),
        child: icon != null
            ? isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          title,
                          style: AppTypography.body(
                            color: textColor ?? AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        Image.asset(icon!, width: 24.w, height: 24.h),
                      ],
                    )
            : Text(
                title,
                style: AppTypography.body(
                  color: textColor ?? AppColors.primary,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
