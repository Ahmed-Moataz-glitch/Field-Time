import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/utils/app_assets.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SuccessfulResetPasswordScreen extends StatelessWidget {
  const SuccessfulResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.divider,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    color: AppColors.greyBorder,
                    borderRadius: BorderRadius.circular(96),
                  ),
                ),
                Image.asset(
                  AppAssets.successfulResetPasswordImage,
                  width: size.width * 0.23,
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              "تمت إعادة تعيين كلمة المرور \nبنجاح",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.surfaceDark,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              "لقد قمت بتغيير كلمة المرور \nبنجاح. يرجى استخدام كلمة المرور الجديدة \nلتسجيل الدخول",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyBorder,
              ),
            ),
            SizedBox(height: size.height * 0.04),
            PrimaryButton(
              title: "الذهاب لتسجيل الدخول",
              onPressed: () {
                context.pushReplacementNamed(AppRouter.loginName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
