import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/core/utils/url_launcher_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/localization/locale_cubit.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/core/widgets/secondary_outlined_button.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_state.dart';

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({super.key});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  late final LocaleCubit _localeCubit;

  @override
  void initState() {
    super.initState();
    _localeCubit = context.read<LocaleCubit>();
  }

  Future<void> _openGoogleMaps(BuildContext context, String address) async {
    await UrlLauncherUtils.openGoogleMaps(context, address);
  }

  void _shareOrCopyInvoice(
    BuildContext context, {
    required String fieldName,
    required String address,
    required String date,
    required String time,
    required String code,
    required double price,
    required double originalPrice,
    required double discount,
    required String? couponCode,
    required bool isArabic,
  }) {
    final invoiceText =
        '''
================================
⚽ FieldTime - إيصال الحجز الفوري
================================
المعلب: $fieldName
العنوان: $address
تاريخ الحجز: $date
التوقيت: $time
كود الحجز: $code
--------------------------------
السعر الأصلي: ${originalPrice.toInt()} ج.م
${discount > 0 ? 'الخصم المطبق ($couponCode): -${discount.toInt()} ج.م\n' : ''}إجمالي المدفوع: ${price <= 0 ? 'مجاناً 🎉' : '${price.toInt()} ج.م'}
================================
نتمنى لكم مباراة ممتعة! ⚽
''';

    Clipboard.setData(ClipboardData(text: invoiceText));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.receipt_long, color: AppColors.primary, size: 28.sp),
                SizedBox(width: 10.w),
                Text(
                  isArabic ? 'إيصال الحجز الإلكتروني' : 'E-Receipt Summary',
                  style: AppTypography.heading3(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                invoiceText,
                style: AppTypography.small(
                  color: Colors.white70,
                ).copyWith(fontFamily: 'monospace'),
              ),
            ),
            SizedBox(height: 20.h),
            PrimaryButton(
              title: isArabic ? 'نسخ بيانات الإيصال' : 'Copy Invoice Details',
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isArabic
                          ? 'تم نسخ إيصال الحجز إلى الحافظة بنجاح! 📋'
                          : 'Receipt copied to clipboard! 📋',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _localeCubit.state.isArabic;
    final todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pushReplacementNamed(AppRouter.appSectionName),
        ),
        title: Text(
          isArabic ? 'تأكيد الحجز الفوري' : 'Instant Booking Confirmation',
          style: AppTypography.heading3(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              final lastBooking = (state is BookingLoaded)
                  ? state.lastCreatedBooking
                  : null;

              final fieldName =
                  lastBooking?.fieldName ??
                  (isArabic ? 'أرينا سبورت (Arena Sport)' : 'Arena Sport');
              final date = lastBooking?.date.isNotEmpty == true
                  ? lastBooking!.date
                  : todayFormatted;
              final time =
                  '${lastBooking?.startTime ?? "19:00"} - ${lastBooking?.endTime ?? "20:00"}';
              final price = lastBooking?.price ?? 350.0;
              final originalPrice = lastBooking?.originalPrice ?? price;
              final discount = lastBooking?.discountAmount ?? 0.0;
              final couponCode = lastBooking?.couponCode;
              final code =
                  lastBooking?.bookingCode ??
                  '#FT-${todayFormatted.replaceAll('-', '')}-0012';
              final address =
                  lastBooking?.fieldAddress ??
                  (isArabic
                      ? 'مدينة نصر - شارع الطيران'
                      : 'Nasr City - El Tayaran St');

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 12.h),

                    // Animated Success Icon
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
                        color: AppColors.backgroundLight,
                      ),
                    ),

                    SizedBox(height: 20.h),
                    Text(
                      isArabic ? 'تم الحجز بنجاح 🎉' : 'Booking Successful! 🎉',
                      style: AppTypography.heading2(
                        color: Colors.white,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      isArabic
                          ? 'تم تأكيد حجزك الفوري في $fieldName بنجاح'
                          : 'Your instant booking at $fieldName is confirmed!',
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
                          _buildDetailRow(
                            isArabic ? 'الملعب' : 'Field',
                            fieldName,
                          ),
                          const Divider(color: Colors.white10),
                          _buildDetailRow(
                            isArabic ? 'العنوان' : 'Address',
                            address,
                          ),
                          const Divider(color: Colors.white10),
                          _buildDetailRow(
                            isArabic ? 'تاريخ الحجز' : 'Date',
                            date,
                          ),
                          const Divider(color: Colors.white10),
                          _buildDetailRow(
                            isArabic ? 'توقيت المباراة' : 'Time',
                            time,
                          ),
                          const Divider(color: Colors.white10),
                          if (discount > 0) ...[
                            _buildDetailRow(
                              isArabic ? 'السعر الأصلي' : 'Original Price',
                              '${originalPrice.toInt()} ج.م',
                            ),
                            const Divider(color: Colors.white10),
                            _buildDetailRow(
                              isArabic
                                  ? 'خصم الكوبون ($couponCode)'
                                  : 'Coupon Discount ($couponCode)',
                              '-${discount.toInt()} ج.م',
                              valueColor: AppColors.success,
                            ),
                            const Divider(color: Colors.white10),
                          ],
                          _buildDetailRow(
                            isArabic ? 'المبلغ المدفوع' : 'Total Paid',
                            price <= 0
                                ? (isArabic ? 'مجاناً 🎉' : 'FREE 🎉')
                                : (isArabic
                                      ? '${price.toInt()} جنيه'
                                      : '${price.toInt()} EGP'),
                            valueColor: price <= 0
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                          const Divider(color: Colors.white10),
                          _buildDetailRow(
                            isArabic ? 'كود الحجز' : 'Booking Code',
                            code,
                            isCode: true,
                          ),

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
                                Icon(
                                  Icons.qr_code_2,
                                  size: 100.sp,
                                  color: Colors.black,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  isArabic
                                      ? 'أبرز هذا الكود لإدارة الملعب عند الدخول'
                                      : 'Show this code to stadium management at entry',
                                  style: AppTypography.small(
                                    color: Colors.black87,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
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
                            onPressed: () => _openGoogleMaps(context, address),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            icon: Icon(
                              Icons.directions,
                              size: 18.sp,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              isArabic ? 'الاتجاهات للملعب' : 'Directions',
                              style: AppTypography.caption(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _shareOrCopyInvoice(
                              context,
                              fieldName: fieldName,
                              address: address,
                              date: date,
                              time: time,
                              code: code,
                              price: price,
                              originalPrice: originalPrice,
                              discount: discount,
                              couponCode: couponCode,
                              isArabic: isArabic,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.white38,
                                width: 1.5,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            icon: Icon(
                              Icons.download_rounded,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                            label: Text(
                              isArabic ? 'تحميل الفاتورة' : 'Invoice Ticket',
                              style: AppTypography.caption(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Navigation to My Bookings Tab (index 1)
                    PrimaryButton(
                      title: isArabic
                          ? 'عرض في قائمة حجوزاتي'
                          : 'View My Bookings',
                      onPressed: () =>
                          context.pushReplacementNamed(AppRouter.appSectionName, extra: 1),
                    ),
                    SizedBox(height: 12.h),

                    // Back to Home Tab (index 0)
                    SecondaryOutlinedButton(
                      title: isArabic
                          ? 'العودة للصفحة الرئيسية'
                          : 'Back to Home',
                      borderColor: Colors.white54,
                      onPressed: () =>
                          context.pushReplacementNamed(AppRouter.appSectionName),
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

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isCode = false,
    Color? valueColor,
  }) {
    final finalColor =
        valueColor ?? (isCode ? AppColors.primary : Colors.white);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption(color: Colors.white70)),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.body(
                color: finalColor,
              ).copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
