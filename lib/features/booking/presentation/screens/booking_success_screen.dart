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
          'تأكيد الحجز الفوري',
          style: AppTypography.heading3(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              final lastBooking = (state is BookingLoaded) ? state.lastCreatedBooking : null;

              final fieldName = lastBooking?.fieldName ?? 'أرينا سبورت (Arena Sport)';
              final date = lastBooking?.date ?? 'الجمعة 24 مايو 2024';
              final time = '${lastBooking?.startTime ?? "19:00"} - ${lastBooking?.endTime ?? "20:00"}';
              final price = '${(lastBooking?.price ?? 350.0).toInt()} جنيه';
              final code = lastBooking?.bookingCode ?? '#FT-2026-0731-0012';
              final address = lastBooking?.fieldAddress ?? 'مدينة نصر - شارع الطيران';

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 12.h),

                    // Animated Success Icon with sparkles
                    Container(
                      width: 90.w,
                      height: 90.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 54.sp,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 20.h),
                    Text(
                      'تم الحجز بنجاح 🎉',
                      style: AppTypography.heading2(color: Colors.white).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'تم تأكيد حجزك الفوري في $fieldName بنجاح',
                      style: AppTypography.body(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24.h),

                    // Booking Ticket Breakdown Card
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('الملعب', fieldName),
                          const Divider(color: Colors.white10),
                          _buildDetailRow('العنوان', address),
                          const Divider(color: Colors.white10),
                          _buildDetailRow('تاريخ الحجز', date),
                          const Divider(color: Colors.white10),
                          _buildDetailRow('توقيت المباراة', time),
                          const Divider(color: Colors.white10),
                          _buildDetailRow('المبلغ المدفوع', price),
                          const Divider(color: Colors.white10),
                          _buildDetailRow('كود الحجز', code, isCode: true),

                          SizedBox(height: 16.h),

                          // QR Code Container
                          Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.qr_code_2, size: 100.sp, color: Colors.black),
                                SizedBox(height: 4.h),
                                Text(
                                  'أبرز هذا الكود لإدارة الملعب عند الدخول',
                                  style: AppTypography.small(color: Colors.black87).copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('جارِ فتح خرائط جوجل للتوجه للملعب...'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary, width: 1.5),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                            icon: Icon(Icons.directions, size: 18.sp, color: AppColors.primary),
                            label: Text('الاتجاهات للملعب', style: AppTypography.caption(color: AppColors.primary)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تنزيل إيصال الحجز بصيغة PDF 📄'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white38, width: 1.5),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                            icon: Icon(Icons.download_rounded, size: 18.sp, color: Colors.white),
                            label: Text('تحميل الفاتورة', style: AppTypography.caption(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    PrimaryButton(
                      title: 'عرض في قائمة حجوزاتي',
                      onPressed: () => context.go('/main'),
                    ),
                    SizedBox(height: 12.h),
                    SecondaryOutlinedButton(
                      title: 'العودة للصفحة الرئيسية',
                      borderColor: Colors.white54,
                      onPressed: () => context.go('/main'),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isCode = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption(color: Colors.white70),
          ),
          Text(
            value,
            style: AppTypography.body(
              color: isCode ? AppColors.primary : Colors.white,
            ).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
