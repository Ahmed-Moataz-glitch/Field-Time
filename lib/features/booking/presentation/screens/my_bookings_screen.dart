import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/localization/locale_cubit.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_state.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().loadBookings();
  }

  void _showCancelConfirmationDialog(BuildContext context, BookingModel booking, bool isArabic) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          isArabic ? 'تأكيد إلغاء الحجز' : 'Confirm Cancellation',
          style: AppTypography.title(color: AppColors.error).copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isArabic
              ? 'هل أنت تأكد من رغبتك في إلغاء حجز ملعب (${booking.fieldName}) بتاريخ ${booking.date}؟'
              : 'Are you sure you want to cancel the booking for (${booking.fieldName}) on ${booking.date}?',
          style: AppTypography.body(color: AppColors.textPrimaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(isArabic ? 'تراجع' : 'Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<BookingCubit>().cancelBooking(booking.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic ? 'تم إلغاء الحجز بنجاح' : 'Reservation cancelled successfully'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(
              isArabic ? 'نعم، إلغاء الحجز' : 'Yes, Cancel',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isArabic = context.watch<LocaleCubit>().state.isArabic;

    final tabsMap = {
      'القادمة': l10n?.upcoming ?? (isArabic ? 'القادمة' : 'Upcoming'),
      'السابقة': l10n?.completed ?? (isArabic ? 'المكتملة' : 'Completed'),
      'ملغاة': l10n?.cancelled ?? (isArabic ? 'الملغاة' : 'Cancelled'),
    };

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l10n?.bookings ?? (isArabic ? 'حجوزاتي' : 'My Bookings'),
          style: AppTypography.heading3(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            // Filter Tabs
            BlocBuilder<BookingCubit, BookingState>(
              builder: (context, state) {
                final activeTab = (state is BookingLoaded) ? state.activeTab : 'القادمة';
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: tabsMap.entries.map((entry) {
                      final key = entry.key;
                      final label = entry.value;
                      final isSelected = key == activeTab;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => context.read<BookingCubit>().changeTab(key),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.cardDark : AppColors.greyLight),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              label,
                              style: AppTypography.caption(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              ).copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
            // Bookings List
            Expanded(
              child: BlocBuilder<BookingCubit, BookingState>(
                builder: (context, state) {
                  if (state is BookingLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  } else if (state is BookingLoaded) {
                    final filteredBookings = state.bookings.where((b) {
                      if (state.activeTab == 'القادمة') return b.status == 'confirmed';
                      if (state.activeTab == 'السابقة') return b.status == 'completed';
                      if (state.activeTab == 'ملغاة') return b.status == 'cancelled';
                      return true;
                    }).toList();

                    if (filteredBookings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 48.sp, color: AppColors.iconGrey),
                            SizedBox(height: 12.h),
                            Text(
                              isArabic ? 'لا توجد حجوزات في هذا القسم' : 'No bookings in this section',
                              style: AppTypography.body(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return _buildBookingItem(context, booking, isDark, isArabic);
                      },
                    );
                  } else if (state is BookingError) {
                    return Center(child: Text(state.message, style: AppTypography.body(color: AppColors.error)));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(BuildContext context, BookingModel booking, bool isDark, bool isArabic) {
    Color statusColor = AppColors.primary;
    String statusLabel = isArabic ? 'مؤكد' : 'Confirmed';

    if (booking.status == 'cancelled') {
      statusColor = AppColors.error;
      statusLabel = isArabic ? 'ملغى' : 'Cancelled';
    } else if (booking.status == 'completed') {
      statusColor = Colors.blue;
      statusLabel = isArabic ? 'مكتمل' : 'Completed';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Section Header
        Padding(
          padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
          child: Text(
            booking.date,
            style: AppTypography.caption(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        // Booking Card Container
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: CachedNetworkImage(
                      imageUrl: booking.fieldImage,
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.fieldName,
                                style: AppTypography.title(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ).copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                statusLabel,
                                style: AppTypography.small(color: statusColor).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          booking.fieldAddress,
                          style: AppTypography.small(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14.sp, color: AppColors.primary),
                            SizedBox(width: 4.w),
                            Text(
                              '${booking.startTime} - ${booking.endTime}',
                              style: AppTypography.caption(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              isArabic ? '${booking.price.toInt()} جنيه' : '${booking.price.toInt()} EGP',
                              style: AppTypography.body(color: AppColors.primary).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (booking.status == 'confirmed') ...[
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showCancelConfirmationDialog(context, booking, isArabic),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        child: Text(
                          isArabic ? 'إلغاء الحجز' : 'Cancel Booking',
                          style: AppTypography.caption(color: AppColors.error).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push('/field-details/${booking.fieldId}'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        child: Text(
                          isArabic ? 'تفاصيل الملعب' : 'Field Details',
                          style: AppTypography.caption(color: AppColors.primary).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
