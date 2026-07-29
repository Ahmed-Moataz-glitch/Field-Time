import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/core/widgets/secondary_outlined_button.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_state.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.go('/main'),
        ),
        title: Text(
          'تأكيد الحجز',
          style: AppTypography.heading3(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              final lastBooking = (state is BookingLoaded) ? state.lastCreatedBooking : null;

              final fieldName = lastBooking?.fieldName ?? 'Arena Sport';
              final date = lastBooking?.date ?? 'الجمعة 24 مايو 2024';
              final time = '${lastBooking?.startTime ?? "19:00"} - ${lastBooking?.endTime ?? "20:00"}';
              final price = '${(lastBooking?.price ?? 350.0).toInt()} جنيه';
              final code = lastBooking?.bookingCode ?? '#FT-2024-0524-0012';

              return Column(
                children: [
                  const Spacer(),
                  // Big Checkmark Circle with sparkles
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 60.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'تم الحجز بنجاح 🎉',
                    style: AppTypography.heading2(color: Colors.white),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'تم حجز ملعب $fieldName بنجاح',
                    style: AppTypography.body(color: Colors.white70),
                  ),
                  SizedBox(height: 32.h),
                  // Breakdown Card
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('الملعب', fieldName),
                        const Divider(color: Colors.white10),
                        _buildDetailRow('التاريخ', date),
                        const Divider(color: Colors.white10),
                        _buildDetailRow('الوقت', time),
                        const Divider(color: Colors.white10),
                        _buildDetailRow('السعر', price),
                        const Divider(color: Colors.white10),
                        _buildDetailRow('رقم الحجز', code),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Actions
                  PrimaryButton(
                    title: 'عرض الحجز',
                    onPressed: () => context.go('/main'),
                  ),
                  SizedBox(height: 14.h),
                  SecondaryOutlinedButton(
                    title: 'العودة للرئيسية',
                    borderColor: Colors.white54,
                    onPressed: () => context.go('/main'),
                  ),
                  SizedBox(height: 10.h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body(color: Colors.white70),
          ),
          Text(
            value,
            style: AppTypography.body(color: Colors.white).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
