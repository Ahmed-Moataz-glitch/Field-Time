import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/primary_button.dart';

class EditProfileSheet extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final String currentCity;
  final Function(String name, String phone, String city) onSubmit;

  const EditProfileSheet({
    super.key,
    required this.currentName,
    required this.currentPhone,
    required this.currentCity,
    required this.onSubmit,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late String _selectedCity;
  bool _isSubmitting = false;

  final List<String> _cities = const [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'المنصورة',
    'طنطا',
    'الزقازيق',
    'أسيوط',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _selectedCity = _cities.contains(widget.currentCity) ? widget.currentCity : 'القاهرة';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      await widget.onSubmit(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _selectedCity,
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
                'تعديل البيانات الشخصية',
                style: AppTypography.heading3(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),

              // Name Field
              TextFormField(
                controller: _nameController,
                style: AppTypography.body(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                validator: (val) => (val == null || val.trim().length < 3) ? 'يرجى كتابة الاسم الثلاثي كاملاً' : null,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  labelStyle: AppTypography.body(color: AppColors.primary),
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20.sp),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.greyLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTypography.body(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                validator: (val) => (val == null || val.trim().length < 10) ? 'يرجى إدخال رقم هاتف صحيح' : null,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  labelStyle: AppTypography.body(color: AppColors.primary),
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary, size: 20.sp),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.greyLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // City Dropdown Field
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                style: AppTypography.body(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  labelText: 'المدينة',
                  labelStyle: AppTypography.body(color: AppColors.primary),
                  prefixIcon: Icon(Icons.location_city_rounded, color: AppColors.primary, size: 20.sp),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.greyLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                ),
                items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCity = val);
                },
              ),
              SizedBox(height: 24.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  title: 'حفظ التغيرات',
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
