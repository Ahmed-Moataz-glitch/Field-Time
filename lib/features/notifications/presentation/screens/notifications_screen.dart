import 'package:field_time/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/localization/locale_cubit.dart';
import 'package:field_time/features/notifications/data/models/notification_model.dart';
import 'package:field_time/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final LocaleCubit _localeCubit;
  late final NotificationsCubit _notificationsCubit;

  @override
  void initState() {
    super.initState();
    _localeCubit = context.read<LocaleCubit>();
    _notificationsCubit = context.read<NotificationsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _notificationsCubit.loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isArabic = _localeCubit.state.isArabic;

    final filters = [
      {'title': isArabic ? 'الكل' : 'All', 'key': 'all'},
      {'title': isArabic ? 'الحجوزات' : 'Bookings', 'key': 'booking'},
      {'title': isArabic ? 'التذكيرات' : 'Reminders', 'key': 'reminder'},
      {'title': isArabic ? 'العروض' : 'Offers', 'key': 'offer'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.notifications ?? (isArabic ? 'الإشعارات' : 'Notifications'),
          style: AppTypography.heading3(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () async {
                    await _notificationsCubit.markAllAsRead();
                  },
                  icon: Icon(Icons.done_all_rounded, size: 16.sp, color: AppColors.primary),
                  label: Text(
                    isArabic ? 'تحديد الكل كمقروء' : 'Mark all as read',
                    style: AppTypography.small(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is NotificationsError) {
              return _buildErrorState(context, state.message, isDark, isArabic);
            }

            if (state is NotificationsLoaded) {
              return Column(
                children: [
                  SizedBox(height: 12.h),

                  // Filter Chips Strip
                  SizedBox(
                    height: 38.h,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: filters.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final key = filter['key']!;
                        final title = filter['title']!;
                        final isSelected = state.selectedFilter == key;

                        return GestureDetector(
                          onTap: () {
                            _notificationsCubit.filterNotifications(key);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.cardDark : AppColors.greyLight),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              title,
                              style: AppTypography.small(
                                color: isSelected
                                    ? AppColors.backgroundLight
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Notifications List or Empty State
                  Expanded(
                    child: state.filteredNotifications.isEmpty
                        ? _buildEmptyState(context, isDark, isArabic)
                        : RefreshIndicator(
                            onRefresh: () async {
                              await _notificationsCubit.loadNotifications(isRefresh: true);
                            },
                            color: AppColors.primary,
                            backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                              itemCount: state.filteredNotifications.length,
                              separatorBuilder: (_, __) => SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final notif = state.filteredNotifications[index];
                                return _buildNotificationCard(context, notif, isDark, isArabic);
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notif, bool isDark, bool isArabic) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (notif.type) {
      case NotificationType.booking:
        iconData = Icons.event_available_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withValues(alpha: 0.12);
        break;
      case NotificationType.reminder:
        iconData = Icons.alarm_rounded;
        iconColor = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.12);
        break;
      case NotificationType.offer:
        iconData = Icons.local_offer_rounded;
        iconColor = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.12);
        break;
      case NotificationType.general:
        iconData = Icons.notifications_active_rounded;
        iconColor = Colors.blue;
        bgColor = Colors.blue.withValues(alpha: 0.12);
        break;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.w),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24.sp),
      ),
      onDismissed: (_) {
        _notificationsCubit.deleteNotification(notif.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'تم حذف الإشعار' : 'Notification deleted'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!notif.isRead) {
            _notificationsCubit.markAsRead(notif.id);
          }

          if (notif.targetId != null && notif.targetId!.isNotEmpty) {
            if (notif.type == NotificationType.booking) {
              context.pushReplacementNamed(AppRouter.appSectionName);
            } else {
              context.pushNamed(AppRouter.fieldDetailsName, queryParameters: {'fieldId': notif.targetId!});
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: notif.isRead
                ? (isDark ? AppColors.cardDark : AppColors.cardLight)
                : (isDark ? AppColors.cardDark.withValues(alpha: 0.8) : AppColors.primary.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: notif.isRead
                  ? (isDark ? Colors.white10 : AppColors.surfaceDark.withValues(alpha: 0.05))
                  : AppColors.primary.withValues(alpha: 0.3),
              width: notif.isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Circle
              CircleAvatar(
                radius: 22.r,
                backgroundColor: bgColor,
                child: Icon(iconData, color: iconColor, size: 20.sp),
              ),
              SizedBox(width: 12.w),

              // Title & Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: AppTypography.body(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ).copyWith(
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            margin: EdgeInsets.only(right: 6.w),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notif.body,
                      style: AppTypography.caption(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      notif.createdAt,
                      style: AppTypography.small(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ).copyWith(fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, bool isArabic) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 50.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              isArabic ? 'لا توجد إشعارات حالياً' : 'No notifications yet',
              style: AppTypography.heading3(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              isArabic
                  ? 'ستظهر لك هنا كافة إشعارات تأكيد الحجز وتذكيرات المباريات وأحدث العروض.'
                  : 'Booking confirmations, match reminders, and special offers will appear here.',
              style: AppTypography.body(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDark, bool isArabic) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              isArabic ? 'حدث خطأ أثناء تحميل الإشعارات' : 'An error occurred loading notifications',
              style: AppTypography.title(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTypography.body(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                context.read<NotificationsCubit>().loadNotifications();
              },
              child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
