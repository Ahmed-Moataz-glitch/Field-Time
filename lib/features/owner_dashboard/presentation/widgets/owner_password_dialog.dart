import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/custom_text_field.dart';
import 'package:field_time/core/widgets/primary_button.dart';

class OwnerPasswordDialog extends StatefulWidget {
  const OwnerPasswordDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const OwnerPasswordDialog(),
    );
    return result ?? false;
  }

  @override
  State<OwnerPasswordDialog> createState() => _OwnerPasswordDialogState();
}

class _OwnerPasswordDialogState extends State<OwnerPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  String? _errorMessage;

  static const String _requiredPassword = 'GLITCH TECH';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _verifyPassword() {
    final entered = _passwordController.text.trim();
    if (entered == _requiredPassword) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = 'كلمة المرور غير صحيحة ! يرجى المحاولة مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: AppColors.primary,
                size: 36.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'دخول لوحة تحكم صاحب الملعب',
              style: AppTypography.heading3(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'يرجى إدخال كلمة المرور المخصصة للوصول إلى لوحة التحكم',
              style: AppTypography.caption(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            CustomTextField(
              controller: _passwordController,
              hintText: 'كلمة المرور',
              isPassword: _obscureText,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.iconGrey,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _errorMessage!,
                  style: AppTypography.small(color: AppColors.error),
                ),
              ),
            ],
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'إلغاء',
                      style: AppTypography.body(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryButton(
                    title: 'دخول',
                    onPressed: _verifyPassword,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
