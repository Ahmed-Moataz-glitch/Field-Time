import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/core/widgets/secondary_outlined_button.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppAssets.welcomeScreenImage,
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    AppColors.backgroundDark.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const Spacer(flex: 2),
                            // Logo Container
                            Container(
                              width: 100.w,
                              height: 100.w,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.sports_soccer,
                                size: 60.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            // Title: FieldTime
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Field',
                                    style: AppTypography.heading1(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'Time',
                                    style: AppTypography.heading1(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.h),
                            // Subtitle
                            Text(
                              l10n.welcomeSubtitle,
                              style: AppTypography.body(color: Colors.white.withValues(alpha: 0.9)),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(flex: 3),
                            // Sign In Button
                            PrimaryButton(
                              title: l10n.login,
                              onPressed: () => context.pushNamed(
                                AppRouter.loginName,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            // Create Account Button
                            SecondaryOutlinedButton(
                              title: l10n.register,
                              onPressed: () => context.pushNamed(
                                AppRouter.registerName,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // Continue as Guest Link
                            GestureDetector(
                              onTap: () => context.pushNamed(
                                AppRouter.appSectionName,
                              ),
                              child: Text(
                                'استمر كزائر',
                                style: AppTypography.body(color: Colors.white70).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white70,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
