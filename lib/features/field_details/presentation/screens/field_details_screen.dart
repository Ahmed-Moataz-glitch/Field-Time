import 'package:cached_network_image/cached_network_image.dart';
import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/core/utils/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:field_time/features/field_details/presentation/cubit/field_details_cubit.dart';
import 'package:field_time/features/field_details/presentation/cubit/field_details_state.dart';

class FieldDetailsScreen extends StatefulWidget {
  final String fieldId;

  const FieldDetailsScreen({super.key, required this.fieldId});

  @override
  State<FieldDetailsScreen> createState() => _FieldDetailsScreenState();
}

class _FieldDetailsScreenState extends State<FieldDetailsScreen> {
  late final FieldDetailsCubit _fieldDetailsCubit;
  late final BookingCubit _bookingCubit;

  @override
  void initState() {
    super.initState();
    _fieldDetailsCubit = getIt<FieldDetailsCubit>();
    _bookingCubit = getIt<BookingCubit>();
  }

  @override
  void dispose() {
    _fieldDetailsCubit.close();
    _bookingCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FieldDetailsView(
      fieldDetailsCubit: _fieldDetailsCubit,
      bookingCubit: _bookingCubit,
    );
  }
}

class _FieldDetailsView extends StatefulWidget {
  final FieldDetailsCubit fieldDetailsCubit;
  final BookingCubit bookingCubit;
  const _FieldDetailsView({
    required this.fieldDetailsCubit,
    required this.bookingCubit,
  });

  @override
  State<_FieldDetailsView> createState() => _FieldDetailsViewState();
}

class _FieldDetailsViewState extends State<_FieldDetailsView> {
  final List<Map<String, String>> _dates = const [
    {'day': 'الخميس', 'num': '23', 'full': 'الخميس 23 مايو'},
    {'day': 'الجمعة', 'num': '24', 'full': 'الجمعة 24 مايو'},
    {'day': 'السبت', 'num': '25', 'full': 'السبت 25 مايو'},
    {'day': 'الأحد', 'num': '26', 'full': 'الأحد 26 مايو'},
    {'day': 'الإثنين', 'num': '27', 'full': 'الإثنين 27 مايو'},
  ];

  final List<Map<String, dynamic>> _timeSlots = const [
    {'time': '06:00', 'status': 'available'},
    {'time': '07:00', 'status': 'available'},
    {'time': '08:00', 'status': 'booked'},
    {'time': '09:00', 'status': 'available'},
    {'time': '10:00', 'status': 'available'},
    {'time': '11:00', 'status': 'available'},
    {'time': '12:00', 'status': 'available'},
    {'time': '13:00', 'status': 'booked'},
    {'time': '14:00', 'status': 'available'},
    {'time': '15:00', 'status': 'available'},
    {'time': '16:00', 'status': 'available'},
    {'time': '17:00', 'status': 'available'},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<FieldDetailsCubit, FieldDetailsState>(
        builder: (context, state) {
          if (state is FieldDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is FieldDetailsLoaded) {
            final field = state.field;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Image Carousel
                      Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: field.mainImage,
                            width: size.width,
                            height: 280.h,
                            fit: BoxFit.cover,
                          ),
                          // Top Buttons (Back & Favorite)
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 8.h,
                            left: 16.w,
                            right: 16.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.surfaceDark
                                      .withValues(alpha: 0.5),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: AppColors.backgroundLight,
                                    ),
                                    onPressed: () => context.pop(),
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: AppColors.surfaceDark
                                      .withValues(alpha: 0.5),
                                  child: IconButton(
                                    icon: Icon(
                                      field.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: field.isFavorite
                                          ? AppColors.error
                                          : AppColors.backgroundLight,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Image Thumbnails Strip
                          Positioned(
                            bottom: 12.h,
                            left: 16.w,
                            right: 16.w,
                            child: Row(
                              children: [
                                for (int i = 0; i < 3; i++) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: CachedNetworkImage(
                                      imageUrl: field.images.length > i
                                          ? field.images[i]
                                          : field.mainImage,
                                      width: 60.w,
                                      height: 60.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                                Container(
                                  width: 60.w,
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: AppColors.surfaceDark.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+12',
                                      style: AppTypography.caption(
                                        color: Colors.white,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Field Name & Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  field.name,
                                  style: AppTypography.heading2(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '(${field.reviewsCount} تقييم)',
                                      style: AppTypography.caption(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      field.rating.toStringAsFixed(1),
                                      style: AppTypography.title(
                                        color: AppColors.primary,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: AppColors.accent,
                                      size: 20.sp,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            // Address & Distance
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16.sp,
                                  color: AppColors.iconGrey,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  field.address,
                                  style: AppTypography.body(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  field.distance,
                                  style: AppTypography.caption(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            // Facilities Cards Grid
                            Row(
                              children: [
                                _facilityCard(
                                  Icons.lightbulb_outline,
                                  'إضاءة ليلية',
                                  isDark,
                                ),
                                SizedBox(width: 10.w),
                                _facilityCard(
                                  Icons.directions_car_outlined,
                                  'مواقف سيارات',
                                  isDark,
                                ),
                                SizedBox(width: 10.w),
                                _facilityCard(Icons.wc, 'دورات مياه', isDark),
                                SizedBox(width: 10.w),
                                _facilityCard(Icons.coffee, 'مقهى', isDark),
                              ],
                            ),
                            SizedBox(height: 28.h),
                            // Select Date Section
                            Text(
                              'اختر التاريخ',
                              style: AppTypography.title(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 14.h),
                            SizedBox(
                              height: 70.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _dates.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(width: 10.w),
                                itemBuilder: (context, index) {
                                  final d = _dates[index];
                                  final isSelected =
                                      d['full'] == state.selectedDate;
                                  return GestureDetector(
                                    onTap: () => context
                                        .read<FieldDetailsCubit>()
                                        .selectDate(d['full']!),
                                    child: Container(
                                      width: 65.w,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : (isDark
                                                  ? AppColors.cardDark
                                                  : AppColors.greyLight),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            d['day']!,
                                            style: AppTypography.small(
                                              color: isSelected
                                                  ? AppColors.backgroundLight
                                                  : (isDark
                                                        ? AppColors
                                                              .textSecondaryDark
                                                        : AppColors
                                                              .textSecondaryLight),
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            d['num']!,
                                            style: AppTypography.body(
                                              color: isSelected
                                                  ? AppColors.backgroundLight
                                                  : (isDark
                                                        ? AppColors
                                                              .textPrimaryDark
                                                        : AppColors
                                                              .textPrimaryLight),
                                            ).copyWith(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 28.h),
                            // Available Slots Section Header + Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'المواعيد المتاحة',
                                  style: AppTypography.title(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    _legendDot(AppColors.primary, 'متاح'),
                                    SizedBox(width: 8.w),
                                    _legendDot(AppColors.error, 'محجوز'),
                                    SizedBox(width: 8.w),
                                    _legendDot(AppColors.iconGrey, 'صيانة'),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            // Time Slots Grid (4 Columns)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 10.h,
                                    crossAxisSpacing: 10.w,
                                    childAspectRatio: 2.2,
                                  ),
                              itemCount: _timeSlots.length,
                              itemBuilder: (context, index) {
                                final slot = _timeSlots[index];
                                final timeStr = slot['time'] as String;
                                final status = slot['status'] as String;
                                final isSelected =
                                    timeStr == state.selectedTimeSlot;

                                Color bgColor;
                                Color textColor;

                                if (status == 'booked') {
                                  bgColor = AppColors.error.withValues(
                                    alpha: 0.85,
                                  );
                                  textColor = AppColors.backgroundLight;
                                } else if (isSelected) {
                                  bgColor = AppColors.primary;
                                  textColor = AppColors.backgroundLight;
                                } else {
                                  bgColor = isDark
                                      ? AppColors.cardDark
                                      : AppColors.greyLight;
                                  textColor = isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight;
                                }

                                return GestureDetector(
                                  onTap: status == 'booked'
                                      ? null
                                      : () => widget.fieldDetailsCubit
                                            .selectTimeSlot(timeStr),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      timeStr,
                                      style: AppTypography.caption(
                                        color: textColor,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Sticky Bottom Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${field.pricePerHour.toInt()} ',
                                    style: AppTypography.heading2(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'جنيه',
                                    style: AppTypography.body(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'السعر / ساعة',
                              style: AppTypography.small(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        PrimaryButton(
                          title: 'احجز الآن',
                          width: 180.w,
                          onPressed: () async {
                            final booking = await widget.bookingCubit.createBooking(
                                  fieldId: field.id,
                                  fieldName: field.name,
                                  fieldAddress: field.address,
                                  fieldImage: field.mainImage,
                                  date: state.selectedDate,
                                  timeSlot:
                                      '${state.selectedTimeSlot ?? "19:00"} - 20:00',
                                  price: field.pricePerHour,
                                );
                            if (booking != null && context.mounted) {
                              context.pushNamed(AppRouter.bookingSuccessName);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is FieldDetailsError) {
            return Center(
              child: Text(
                state.message,
                style: AppTypography.body(color: AppColors.error),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _facilityCard(IconData icon, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.greyLight,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22.sp,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: AppTypography.small(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: AppTypography.small(color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
