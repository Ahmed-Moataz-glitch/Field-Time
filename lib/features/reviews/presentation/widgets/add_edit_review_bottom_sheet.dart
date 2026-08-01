import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/features/field_details/data/models/review_model.dart';

class AddEditReviewBottomSheet extends StatefulWidget {
  final String fieldId;
  final ReviewModel? existingReview;
  final Function(double rating, String comment) onSubmit;

  const AddEditReviewBottomSheet({
    super.key,
    required this.fieldId,
    this.existingReview,
    required this.onSubmit,
  });

  @override
  State<AddEditReviewBottomSheet> createState() => _AddEditReviewBottomSheetState();
}

class _AddEditReviewBottomSheetState extends State<AddEditReviewBottomSheet> {
  late double _rating;
  late TextEditingController _commentController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final Map<int, String> _ratingLabels = const {
    5: 'ممتاز جداً 🔥',
    4: 'جيد جداً 👍',
    3: 'جيد ⚽',
    2: 'مقبول 😐',
    1: 'ضعيف 👎',
  };

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 5.0;
    _commentController = TextEditingController(text: widget.existingReview?.comment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      await widget.onSubmit(_rating, _commentController.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingReview != null;

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
              // Bottom sheet handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                isEditing ? 'تعديل التقييم' : 'أضف تقييمك للملعب',
                style: AppTypography.heading3(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),

              // Interactive Star Rating Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = (index + 1).toDouble();
                  final isFilled = starValue <= _rating;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = starValue;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isFilled ? AppColors.accent : (isDark ? Colors.white24 : AppColors.iconGrey),
                          size: 38.sp,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 8.h),

              // Rating label text
              Text(
                _ratingLabels[_rating.round()] ?? '',
                style: AppTypography.title(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 20.h),

              // Comment TextField
              TextFormField(
                controller: _commentController,
                maxLines: 4,
                style: AppTypography.body(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى كتابة تعليقك عن الملعب';
                  }
                  if (val.trim().length < 3) {
                    return 'التعليق يجب أن يتكون من 3 حروف على الأقل';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'شاركنا تجربتك وانطباعك عن جودة النجيل والإضاءة والمرافق...',
                  hintStyle: AppTypography.body(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.greyLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
              SizedBox(height: 24.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  title: isEditing ? 'تعديل التقييم' : 'إرسال التقييم',
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
