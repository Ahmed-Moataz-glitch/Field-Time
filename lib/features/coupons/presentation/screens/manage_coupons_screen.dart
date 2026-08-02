import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/features/coupons/data/models/coupon_model.dart';
import 'package:field_time/features/coupons/data/repositories/coupon_repository.dart';
import 'package:field_time/features/coupons/presentation/cubit/coupon_management_cubit.dart';
import 'package:field_time/features/coupons/presentation/cubit/coupon_management_state.dart';

class ManageCouponsScreen extends StatelessWidget {
  const ManageCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CouponManagementCubit(CouponRepository())..loadCoupons(),
      child: const _ManageCouponsView(),
    );
  }
}

class _ManageCouponsView extends StatelessWidget {
  const _ManageCouponsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة الكوبونات والعروض',
          style: AppTypography.heading3(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primary, size: 26.sp),
            onPressed: () async {
              await context.push('/create-coupon').then(
                (value) {
                  if (context.mounted) {
                    context.read<CouponManagementCubit>().loadCoupons();
                  }
                },
              );
              if (context.mounted) {
                context.read<CouponManagementCubit>().loadCoupons();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<CouponManagementCubit, CouponManagementState>(
          builder: (context, state) {
            if (state is CouponManagementLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is CouponManagementError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                    SizedBox(height: 12.h),
                    Text(state.message, style: AppTypography.body(color: AppColors.error)),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<CouponManagementCubit>().loadCoupons(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            } else if (state is CouponManagementLoaded) {
              final coupons = state.coupons;

              if (coupons.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 64.sp, color: AppColors.primary),
                      SizedBox(height: 16.h),
                      Text('لا توجد كوبونات حالياً', style: AppTypography.title(color: AppColors.textSecondaryLight)),
                      SizedBox(height: 20.h),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await context.push('/create-coupon');
                          if (context.mounted) {
                            context.read<CouponManagementCubit>().loadCoupons();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('إنشاء أول كوبون', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<CouponManagementCubit>().loadCoupons(),
                color: AppColors.primary,
                child: ListView.separated(
                  padding: EdgeInsets.all(20.w),
                  itemCount: coupons.length,
                  separatorBuilder: (context, index) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    final coupon = coupons[index];
                    return _couponCard(context, coupon, isDark);
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/create-coupon');
          if (context.mounted) {
            context.read<CouponManagementCubit>().loadCoupons();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('كوبون جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _couponCard(BuildContext context, CouponModel coupon, bool isDark) {
    String typeLabel = '';
    Color typeColor = AppColors.primary;

    if (coupon.discountType == 'free') {
      typeLabel = 'حجز مجاني (100%)';
      typeColor = AppColors.success;
    } else if (coupon.discountType == 'percentage') {
      typeLabel = 'خصم ${coupon.discountValue.toInt()}%';
      typeColor = Colors.orange;
    } else {
      typeLabel = 'خصم ${coupon.discountValue.toInt()} ج.م';
      typeColor = AppColors.primary;
    }

    final expiryStr = coupon.expiresAt != null
        ? DateFormat('yyyy-MM-dd').format(coupon.expiresAt!)
        : 'بدون تاريخ انتهاء';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: coupon.isActive
              ? AppColors.primary.withValues(alpha: 0.2)
              : (isDark ? Colors.white10 : Colors.black12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  coupon.code,
                  style: AppTypography.title(color: typeColor).copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Switch.adaptive(
                value: coupon.isActive,
                activeTrackColor: AppColors.primary,
                onChanged: (val) {
                  context.read<CouponManagementCubit>().toggleCouponActive(coupon.id, val);
                },
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'نوع العرض: $typeLabel',
                style: AppTypography.body(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              if (coupon.minBookingAmount > 0)
                Text(
                  'الحد الأدنى: ${coupon.minBookingAmount.toInt()} ج.م',
                  style: AppTypography.caption(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تاريخ الانتهاء: $expiryStr',
                style: AppTypography.caption(
                  color: coupon.isExpired ? AppColors.error : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
              Text(
                'عدد الاستخدامات: ${coupon.usedCount}${coupon.usageLimit != null ? ' / ${coupon.usageLimit}' : ''}',
                style: AppTypography.caption(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
