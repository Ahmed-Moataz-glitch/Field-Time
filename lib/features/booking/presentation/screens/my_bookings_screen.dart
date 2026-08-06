import 'package:cached_network_image/cached_network_image.dart';
import 'package:field_time/core/utils/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_state.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late final BookingCubit bookingCubit;
  final List<String> _tabs = const ['القادمة', 'السابقة', 'ملغاة'];

  @override
  void initState() {
    super.initState();
    bookingCubit = getIt<BookingCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await bookingCubit.loadBookings();
    });
  }

  @override
  void dispose() {
    bookingCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'حجوزاتي',
          style: AppTypography.heading3(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
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
                    children: _tabs.map((tab) {
                      final isSelected = tab == activeTab;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => bookingCubit.changeTab(tab),
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
                              tab,
                              style: AppTypography.caption(
                                color: isSelected
                                    ? AppColors.backgroundLight
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
                        child: Text(
                          'لا توجد حجوزات في هذا القسم',
                          style: AppTypography.body(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return _buildBookingItem(booking, isDark);
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

  Widget _buildBookingItem(BookingModel booking, bool isDark) {
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
                            Text(
                              booking.fieldName,
                              style: AppTypography.title(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'مؤكد',
                                style: AppTypography.small(color: AppColors.primary).copyWith(
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
                              '${booking.price.toInt()} جنيه',
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
              SizedBox(height: 16.h),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async => await bookingCubit.cancelBooking(booking.id),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: Text(
                        'إلغاء الحجز',
                        style: AppTypography.caption(color: AppColors.error).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: Text(
                        'تفاصيل',
                        style: AppTypography.caption(color: AppColors.primary).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
