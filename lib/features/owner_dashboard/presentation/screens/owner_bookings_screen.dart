import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/custom_text_field.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';
import 'package:field_time/features/owner_dashboard/data/repositories/owner_repository.dart';
import 'package:field_time/features/owner_dashboard/presentation/cubit/owner_dashboard_cubit.dart';
import 'package:field_time/features/owner_dashboard/presentation/cubit/owner_dashboard_state.dart';

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OwnerDashboardCubit(OwnerRepository())..loadDashboardData(),
      child: const _OwnerBookingsView(),
    );
  }
}

class _OwnerBookingsView extends StatefulWidget {
  const _OwnerBookingsView();

  @override
  State<_OwnerBookingsView> createState() => _OwnerBookingsViewState();
}

class _OwnerBookingsViewState extends State<_OwnerBookingsView> {
  final TextEditingController _searchController = TextEditingController();
  String _activeTab = 'الكل';
  final List<String> _tabs = const ['الكل', 'المؤكدة', 'المكتملة', 'الملغاة'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة حجوزات اللاعبين',
          style: AppTypography.heading3(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomTextField(
                controller: _searchController,
                hintText: 'البحث باسم الملعب أو كود الحجز...',
                prefixIcon: const Icon(Icons.search),
                onChanged: (_) => setState(() {}),
              ),
            ),

            SizedBox(height: 14.h),

            // Filter Tabs Strip
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = tab == _activeTab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = tab),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.cardDark : AppColors.greyLight),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tab,
                          style: AppTypography.caption(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ).copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 16.h),

            // Bookings List
            Expanded(
              child: BlocBuilder<OwnerDashboardCubit, OwnerDashboardState>(
                builder: (context, state) {
                  if (state is OwnerDashboardLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  } else if (state is OwnerDashboardLoaded) {
                    final query = _searchController.text.trim().toLowerCase();

                    final filtered = state.bookings.where((b) {
                      // 1. Filter by Tab
                      if (_activeTab == 'المؤكدة' && b.status != 'confirmed') return false;
                      if (_activeTab == 'المكتملة' && b.status != 'completed') return false;
                      if (_activeTab == 'الملغاة' && b.status != 'cancelled') return false;

                      // 2. Filter by Search Query
                      if (query.isNotEmpty) {
                        return b.fieldName.toLowerCase().contains(query) ||
                            b.bookingCode.toLowerCase().contains(query);
                      }

                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد حجوزات مطابقة',
                          style: AppTypography.body(color: AppColors.textSecondaryLight),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final booking = filtered[index];
                              return _buildOwnerBookingCard(context, booking, isDark);
                            },
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    );
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

  Widget _buildOwnerBookingCard(BuildContext context, BookingModel booking, bool isDark) {
    Color statusColor = AppColors.primary;
    String statusLabel = 'مؤكد';

    if (booking.status == 'cancelled') {
      statusColor = AppColors.error;
      statusLabel = 'ملغى';
    } else if (booking.status == 'completed') {
      statusColor = Colors.blue;
      statusLabel = 'مكتمل';
    }

    return Container(
      padding: EdgeInsets.all(16.w),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.fieldName,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: AppTypography.title(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
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
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 14.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                '${booking.date} | ${booking.startTime} - ${booking.endTime}',
                style: AppTypography.caption(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.confirmation_number_outlined, size: 14.sp, color: AppColors.iconGrey),
              SizedBox(width: 6.w),
              Text(
                booking.bookingCode,
                style: AppTypography.small(color: AppColors.primary),
              ),
              const Spacer(),
              Text(
                '${booking.price.toInt()} ج.م',
                style: AppTypography.body(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('الاتصال بالمستأجر: 01012345678')),
                    );
                  },
                  icon: Icon(Icons.phone_outlined, size: 16.sp, color: AppColors.primary),
                  label: Text('اتصال بالمستأجر', style: AppTypography.small(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
