import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';

class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Pick a single image from Camera
  Future<String?> pickImageFromCamera({int imageQuality = 85}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
      );
      return image?.path;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick a single image from Gallery
  Future<String?> pickImageFromGallery({int imageQuality = 85}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
      );
      return image?.path;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick multiple images from Gallery
  Future<List<String>> pickMultipleImagesFromGallery({int imageQuality = 85}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: imageQuality,
      );
      return images.map((img) => img.path).toList();
    } catch (e) {
      debugPrint('Error picking multiple images from gallery: $e');
      return [];
    }
  }

  /// Display a modal bottom sheet to let the user select between Camera & Gallery
  Future<String?> showImageSourceSheet(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
                'اختيار صورة',
                style: AppTypography.heading3(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 24.sp),
                ),
                title: Text(
                  'التقاط صورة بالنظارة/الكاميرا',
                  style: AppTypography.body(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'استخدام كاميرا الجهاز التقاط صورة جديدة',
                  style: AppTypography.caption(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                onTap: () async {
                  final path = await pickImageFromCamera();
                  if (context.mounted) {
                    Navigator.of(context).pop(path);
                  }
                },
              ),
              const Divider(height: 1, color: AppColors.greyBorder),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 24.sp),
                ),
                title: Text(
                  'اختيار من معرض الصور',
                  style: AppTypography.body(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'تصفح ملفات الصور المخزنة على جهازك',
                  style: AppTypography.caption(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                onTap: () async {
                  final path = await pickImageFromGallery();
                  if (context.mounted) {
                    Navigator.of(context).pop(path);
                  }
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }
}
