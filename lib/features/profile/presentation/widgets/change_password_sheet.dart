import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/primary_button.dart';

class ChangePasswordSheet extends StatefulWidget {
  final Function(String currentPassword, String newPassword) onSubmit;

  const ChangePasswordSheet({
    super.key,
    required this.onSubmit,
  });

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      await widget.onSubmit(
        _currentPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20.w,
        right: 20.w,
        top: 20.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'تغيير كلمة المرور',
                style: AppTypography.heading3(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),

              // Current Password Field
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                style: AppTypography.body(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                validator: (val) => (val == null || val.length < 6) ? 'كلمة المرور الحالية يجب أن لا تقل عن 6 أحرف' : null,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  labelStyle: AppTypography.body(color: AppColors.primary),
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20.sp),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, color: AppColors.iconGrey),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.greyLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 14.h),

              // New Password Field
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                style: AppTypography.body(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                validator: (val) => (val == null || val.length < 6) ? 'كلمة المرور الجديدة يجب أن لا تقل عن 6 أحرف' : null,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  labelStyle: AppTypography.body(color: AppColors.primary),
                  prefixIcon: Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 20.sp),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: AppColors.iconGrey),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.greyLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 14.h),

              // Confirm New Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                style: AppTypography.body(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'يرجى تأكيد كلمة المرور الجديدة';
                  if (val != _newPasswordController.text) return 'كلمتا المرور غير متطابقتين';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                  labelStyle: AppTypography.body(color: AppColors.primary),
                  prefixIcon: Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20.sp),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppColors.iconGrey),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.greyLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 24.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  title: 'تحديث كلمة المرور',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
