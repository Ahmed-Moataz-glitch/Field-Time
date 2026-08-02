import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/features/owner_dashboard/data/repositories/owner_repository.dart';
import 'package:field_time/features/owner_dashboard/presentation/cubit/owner_dashboard_cubit.dart';
import 'package:field_time/features/owner_dashboard/presentation/cubit/owner_dashboard_state.dart';

class OwnerStatisticsScreen extends StatelessWidget {
  const OwnerStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OwnerDashboardCubit(OwnerRepository())..loadDashboardData(),
      child: const _OwnerStatisticsView(),
    );
  }
}

class _OwnerStatisticsView extends StatelessWidget {
  const _OwnerStatisticsView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إحصائيات الأرباح والأداء',
          style: AppTypography.heading3(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<OwnerDashboardCubit, OwnerDashboardState>(
          builder: (context, state) {
            if (state is OwnerDashboardLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is OwnerDashboardLoaded) {
              final stats = state.stats;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Total Revenue Summary Card
                    Container(
                      width: size.width,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إجمالي أرباح هذا الشهر',
                            style: AppTypography.body(color: Colors.white70),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '${stats.totalEarnings.toInt()} جنيه',
                            style: AppTypography.heading1(
                              color: Colors.white,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _whiteMetricTile(
                                'عدد الحجوزات',
                                '${stats.totalBookings} حجز',
                              ),
                              _whiteMetricTile(
                                'نسبة الإشغال',
                                '${stats.occupancyRate}%',
                              ),
                              _whiteMetricTile(
                                'الملاعب النشطة',
                                '${stats.activeFieldsCount} ملاعب',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // 2. Monthly Revenue Chart Title
                    Text(
                      'مخطط الإيرادات الشهرية',
                      style: AppTypography.title(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 14.h),

                    // Monthly Revenue Bar Chart Visualization
                    Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 160.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: stats.monthlyRevenue.map((dp) {
                                final maxRev = 20000.0;
                                final heightRatio = (dp.revenue / maxRev).clamp(
                                  0.15,
                                  1.0,
                                );

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${(dp.revenue / 1000).toStringAsFixed(1)}k',
                                      style: AppTypography.small(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ).copyWith(fontSize: 10.sp),
                                    ),
                                    SizedBox(height: 4.h),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      width: 22.w,
                                      height: 110.h * heightRatio,
                                      decoration: BoxDecoration(
                                        color: dp.month == 'يوليو'
                                            ? AppColors.primary
                                            : AppColors.primary.withValues(
                                                alpha: 0.35,
                                              ),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(8.r),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      dp.month,
                                      style:
                                          AppTypography.small(
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight,
                                          ).copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10.sp,
                                          ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // 3. Peak Booking Hours Card
                    Text(
                      'أوقات الذروة والمباريات الأكثر طلباً',
                      style: AppTypography.title(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),

                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        children: [
                          _peakHourRow(
                            'الساعة 19:00 - 20:00 (المساء)',
                            '88% نسبة أشغال',
                            isDark,
                          ),
                          const Divider(height: 16),
                          _peakHourRow(
                            'الساعة 21:00 - 22:00 (السهرة)',
                            '94% نسبة أشغال',
                            isDark,
                          ),
                          const Divider(height: 16),
                          _peakHourRow(
                            'الساعة 17:00 - 18:00 (العصر)',
                            '65% نسبة أشغال',
                            isDark,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _whiteMetricTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.body(
            color: Colors.white,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: AppTypography.small(color: Colors.white70)),
      ],
    );
  }

  Widget _peakHourRow(String time, String percentage, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time_filled,
              size: 18.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              time,
              style: AppTypography.body(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold, fontSize: 13.sp),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            percentage,
            style: AppTypography.caption(
              color: AppColors.primary,
            ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
