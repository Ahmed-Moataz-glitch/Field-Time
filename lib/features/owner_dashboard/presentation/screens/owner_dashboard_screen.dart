import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';
import 'package:field_time/features/home/data/models/field_model.dart';
import 'package:field_time/features/owner_dashboard/data/repositories/owner_repository.dart';
import 'package:field_time/features/owner_dashboard/presentation/cubit/owner_dashboard_cubit.dart';
import 'package:field_time/features/owner_dashboard/presentation/cubit/owner_dashboard_state.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OwnerDashboardCubit(OwnerRepository())..loadDashboardData(),
      child: const _OwnerDashboardView(),
    );
  }
}

class _OwnerDashboardView extends StatelessWidget {
  const _OwnerDashboardView();

  void _showDeleteDialog(BuildContext context, FieldModel field) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'تأكيد حذف الملعب',
          style: AppTypography.title(color: AppColors.error).copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت تأكد من حذف ملعب (${field.name})؟ سيتم التحقق من عدم وجود حجوزات قائمة أولاً.',
          style: AppTypography.body(color: AppColors.textPrimaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<OwnerDashboardCubit>().deleteField(field.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم صاحب الملعب',
          style: AppTypography.heading3(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primary, size: 26.sp),
            onPressed: () => context.push('/add-field'),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<OwnerDashboardCubit, OwnerDashboardState>(
          listener: (context, state) {
            if (state is OwnerOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is OwnerDashboardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OwnerDashboardLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is OwnerDashboardLoaded) {
              final stats = state.stats;
              final fields = state.fields;
              final bookings = state.bookings;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Analytics KPI Cards Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1.3,
                      children: [
                        _kpiCard(
                          title: 'إجمالي الأرباح',
                          value: '${stats.totalEarnings.toInt()} ج.م',
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          isDark: isDark,
                        ),
                        _kpiCard(
                          title: 'الحجوزات الكلية',
                          value: '${stats.totalBookings} حجز',
                          icon: Icons.bookmark_added_outlined,
                          color: Colors.blue,
                          isDark: isDark,
                        ),
                        _kpiCard(
                          title: 'الملاعب النشطة',
                          value: '${stats.activeFieldsCount} ملعب',
                          icon: Icons.sports_soccer_outlined,
                          color: Colors.orange,
                          isDark: isDark,
                        ),
                        _kpiCard(
                          title: 'نسبة الإشغال',
                          value: '${stats.occupancyRate}%',
                          icon: Icons.trending_up,
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // 2. Quick Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: _actionTile(
                            title: 'إضافة ملعب جديد',
                            icon: Icons.add_business_outlined,
                            color: AppColors.primary,
                            isDark: isDark,
                            onTap: () => context.push('/add-field'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _actionTile(
                            title: 'إدارة الحجوزات',
                            icon: Icons.calendar_month_outlined,
                            color: Colors.blue,
                            isDark: isDark,
                            onTap: () => context.push('/owner-bookings'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _actionTile(
                            title: 'الإحصائيات',
                            icon: Icons.bar_chart_outlined,
                            color: Colors.purple,
                            isDark: isDark,
                            onTap: () => context.push('/owner-stats'),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 28.h),

                    // 3. My Fields Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ملاعبي (${fields.length})',
                          style: AppTypography.title(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/add-field'),
                          icon: Icon(Icons.add, size: 18.sp, color: AppColors.primary),
                          label: Text(
                            'إضافة ملعب',
                            style: AppTypography.caption(color: AppColors.primary).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // My Fields List
                    if (fields.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Text(
                            'لم تقم بإضافة أية ملاعب بعد.',
                            style: AppTypography.body(color: AppColors.textSecondaryLight),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: fields.length,
                        separatorBuilder: (context, index) => SizedBox(height: 14.h),
                        itemBuilder: (context, index) {
                          final field = fields[index];
                          return _buildOwnerFieldCard(context, field, isDark);
                        },
                      ),

                    SizedBox(height: 28.h),

                    // 4. Recent Player Bookings Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'أحدث حجوزات اللاعبين',
                          style: AppTypography.title(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => context.push('/owner-bookings'),
                          child: Text(
                            'عرض الكل',
                            style: AppTypography.caption(color: AppColors.primary).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Bookings Preview
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bookings.take(3).length,
                      separatorBuilder: (context, index) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final b = bookings[index];
                        return _buildRecentBookingTile(b, isDark);
                      },
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              );
            } else if (state is OwnerDashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                    SizedBox(height: 12.h),
                    Text(state.message, style: AppTypography.body(color: AppColors.error)),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<OwnerDashboardCubit>().loadDashboardData(),
                      child: const Text('إعادة المحاولة'),
                    ),
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

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18.r),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, size: 18.sp, color: color),
              ),
              Icon(Icons.arrow_upward, size: 14.sp, color: AppColors.success),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: AppTypography.heading3(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: AppTypography.small(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24.sp, color: color),
            SizedBox(height: 6.h),
            Text(
              title,
              style: AppTypography.small(color: color).copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerFieldCard(BuildContext context, FieldModel field, bool isDark) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
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
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: CachedNetworkImage(
                  imageUrl: field.mainImage,
                  width: 85.w,
                  height: 85.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      style: AppTypography.title(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ).copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${field.city} - ${field.area}',
                      style: AppTypography.small(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${field.pricePerHour.toInt()} ج.م / ساعة',
                      style: AppTypography.caption(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Availability Switch
              Row(
                children: [
                  Text(
                    'حالة الملعب:',
                    style: AppTypography.small(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Switch.adaptive(
                    value: field.isAvailableToday,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) {
                      context.read<OwnerDashboardCubit>().toggleFieldAvailability(field.id, val);
                    },
                  ),
                  Text(
                    field.isAvailableToday ? 'متاح' : 'مغلق',
                    style: AppTypography.small(
                      color: field.isAvailableToday ? AppColors.success : AppColors.error,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // Edit & Delete Action Buttons
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: Colors.blue, size: 20.sp),
                    onPressed: () => context.push('/edit-field/${field.id}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20.sp),
                    onPressed: () => _showDeleteDialog(context, field),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookingTile(BookingModel booking, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.greyLight,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Icon(Icons.sports_soccer, size: 16.sp, color: AppColors.primary),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.fieldName,
                    style: AppTypography.body(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${booking.date} | ${booking.startTime}',
                    style: AppTypography.small(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${booking.price.toInt()} ج.م',
            style: AppTypography.caption(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
