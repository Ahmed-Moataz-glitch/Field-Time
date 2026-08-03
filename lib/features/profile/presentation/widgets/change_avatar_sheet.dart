import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/services/image_picker_service.dart';
import 'package:field_time/core/widgets/app_image.dart';
import 'package:field_time/core/widgets/primary_button.dart';

class ChangeAvatarSheet extends StatefulWidget {
  final String currentAvatar;
  final Function(String avatarUrl) onSelected;

  const ChangeAvatarSheet({
    super.key,
    required this.currentAvatar,
    required this.onSelected,
  });

  @override
  State<ChangeAvatarSheet> createState() => _ChangeAvatarSheetState();
}

class _ChangeAvatarSheetState extends State<ChangeAvatarSheet> {
  late String _selectedUrl;
  bool _isSubmitting = false;
  final ImagePickerService _pickerService = ImagePickerService();

  final List<String> _presetAvatars = const [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1628157582853-a796fa650a6a?auto=format&fit=crop&q=80&w=400',
  ];

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.currentAvatar;
  }

  void _pickCustomImage() async {
    final pickedPath = await _pickerService.showImageSourceSheet(context);
    if (pickedPath != null) {
      setState(() {
        _selectedUrl = pickedPath;
      });
    }
  }

  void _submit() async {
    setState(() => _isSubmitting = true);
    await widget.onSelected(_selectedUrl);
    if (mounted) {
      Navigator.of(context).pop();
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
              'تغيير الصورة الشخصية',
              style: AppTypography.heading3(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'التقط صورة بالكاميرا، اختر من المعرض، أو حدد رمزا جاهزا',
              style: AppTypography.caption(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),

            // Current Preview if custom image selected
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3.w),
              ),
              child: ClipOval(
                child: AppImage(
                  imagePath: _selectedUrl,
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Button to pick image from camera/gallery
            OutlinedButton.icon(
              onPressed: _pickCustomImage,
              icon: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
              label: Text(
                'التقاط أو اختيار صورة جديدة',
                style: AppTypography.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
            ),
            SizedBox(height: 24.h),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'أو اختر رمزاً إفتراضياً:',
                style: AppTypography.caption(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Grid of preset avatars
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1,
              ),
              itemCount: _presetAvatars.length,
              itemBuilder: (context, index) {
                final url = _presetAvatars[index];
                final isSelected = url == _selectedUrl;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUrl = url;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 3.5.w,
                      ),
                    ),
                    child: ClipOval(
                      child: AppImage(
                        imagePath: url,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                title: 'حفظ الصورة',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
