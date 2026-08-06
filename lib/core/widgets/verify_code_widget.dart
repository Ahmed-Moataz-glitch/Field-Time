import 'package:field_time/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyCodeWidget extends StatefulWidget {
  final PinInputController pinController;
  const VerifyCodeWidget({super.key, required this.pinController});

  @override
  State<VerifyCodeWidget> createState() => _VerifyCodeWidgetState();
}

class _VerifyCodeWidgetState extends State<VerifyCodeWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialPinField(
      pinController: widget.pinController,
      length: 6,
      theme: MaterialPinTheme(
        fillColor: AppColors.divider,
        focusedFillColor: AppColors.divider,
        focusedBorderColor: AppColors.primary,
        filledFillColor: AppColors.divider,
        filledBorderColor: AppColors.primary,
        followingFillColor: AppColors.divider,
        followingBorderColor: AppColors.greyBorder,
        completeFillColor: AppColors.divider,
        completeBorderColor: AppColors.primary,
        cursorColor: AppColors.primary,
        borderColor: AppColors.greyBorder,
        textStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          shadows: [
            Shadow(
              color: AppColors.primary,
              blurRadius: 2.r,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        errorBorderColor: AppColors.error,
        errorTextStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.error,
        ),
      ),
      onCompleted: (String value) {
        debugPrint('Completed: $value');
      },
    );
  }
}