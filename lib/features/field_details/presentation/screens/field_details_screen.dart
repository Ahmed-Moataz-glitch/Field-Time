import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/core/widgets/rating_badge.dart';
import 'package:field_time/features/field_details/data/models/review_model.dart';
import 'package:field_time/features/field_details/presentation/cubit/field_details_cubit.dart';
import 'package:field_time/features/field_details/presentation/cubit/field_details_state.dart';
import 'package:field_time/features/home/data/models/field_model.dart';
import 'package:field_time/features/home/data/repositories/field_repository.dart';
import 'package:field_time/features/reviews/presentation/widgets/add_edit_review_bottom_sheet.dart';
import 'package:field_time/features/favorites/presentation/cubit/favorites_cubit.dart';

class FieldDetailsScreen extends StatelessWidget {
  final String fieldId;

  const FieldDetailsScreen({
    super.key,
    required this.fieldId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FieldDetailsCubit(FieldRepository())..loadFieldDetails(fieldId),
      child: _FieldDetailsView(fieldId: fieldId),
    );
  }
}

class _FieldDetailsView extends StatefulWidget {
  final String fieldId;
  const _FieldDetailsView({required this.fieldId});

  @override
  State<_FieldDetailsView> createState() => _FieldDetailsViewState();
}

class _FieldDetailsViewState extends State<_FieldDetailsView> {
  late PageController _pageController;

  final List<Map<String, dynamic>> _timeSlots = const [
    {'time': '16:00', 'status': 'available'},
    {'time': '17:00', 'status': 'available'},
    {'time': '18:00', 'status': 'available'},
    {'time': '19:00', 'status': 'booked'},
    {'time': '20:00', 'status': 'available'},
    {'time': '21:00', 'status': 'available'},
    {'time': '22:00', 'status': 'booked'},
    {'time': '23:00', 'status': 'available'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<DateTime> _getAvailableDates() {
    final now = DateTime.now();
    return List.generate(7, (index) => now.add(Duration(days: index)));
  }

  String _formatDayName(DateTime date) {
    final arabicDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return arabicDays[date.weekday % 7];
  }

  String _formatMonthName(DateTime date) {
    final arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return arabicMonths[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
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
            final imagesList = field.images.isNotEmpty ? field.images : [field.mainImage];
            final availableDates = _getAvailableDates();

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 110.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Hero Image Slider with Gallery Indicators
                      _buildImageSlider(context, field, imagesList, state),

                      SizedBox(height: 16.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 2. Field Name & Badges
                            _buildTitleAndBadges(field, isDark),

                            SizedBox(height: 12.h),

                            // Address & Distance Row
                            _buildAddressRow(field, isDark),

                            SizedBox(height: 16.h),

                            // 3. Quick Action Buttons Row (Call, Map, Share)
                            _buildQuickActionsRow(context, field, isDark),

                            SizedBox(height: 24.h),
                            const Divider(),

                            // 4. Description Section
                            SizedBox(height: 16.h),
                            _buildDescriptionSection(context, state, isDark),

                            SizedBox(height: 24.h),
                            const Divider(),

                            // 5. Facilities Section
                            SizedBox(height: 16.h),
                            _buildFacilitiesSection(field, isDark),

                            SizedBox(height: 24.h),
                            const Divider(),

                            // 6. Location & Map Preview Card
                            SizedBox(height: 16.h),
                            _buildMapCard(context, field, isDark),

                            SizedBox(height: 24.h),
                            const Divider(),

                            // 7. Interactive Date Picker Strip
                            SizedBox(height: 16.h),
                            _buildDatePickerSection(context, state, availableDates, isDark),

                            SizedBox(height: 24.h),

                            // 8. Available Time Slots Grid
                            _buildTimeSlotsSection(context, state, isDark),

                            SizedBox(height: 24.h),
                            const Divider(),

                            // 9. Reviews Section
                            SizedBox(height: 16.h),
                            _buildReviewsSection(field, state.reviews, isDark),

                            SizedBox(height: 24.h),
                            const Divider(),

                            // 10. Related Fields Carousel
                            if (state.relatedFields.isNotEmpty) ...[
                              SizedBox(height: 16.h),
                              _buildRelatedFieldsSection(context, state.relatedFields, isDark),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Sticky Bottom Booking Bar
                _buildStickyBottomBar(context, field, state, isDark),
              ],
            );
          } else if (state is FieldDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                  SizedBox(height: 12.h),
                  Text(state.message, style: AppTypography.body(color: AppColors.error)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<FieldDetailsCubit>().loadFieldDetails(widget.fieldId),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Widget 1: Image Slider
  Widget _buildImageSlider(
    BuildContext context,
    FieldModel field,
    List<String> images,
    FieldDetailsLoaded state,
  ) {
    return Stack(
      children: [
        SizedBox(
          height: 300.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              context.read<FieldDetailsCubit>().changeImageIndex(index);
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                width: double.infinity,
                height: 300.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.sports_soccer, size: 60, color: Colors.white54),
                ),
              );
            },
          ),
        ),

        // Gradient overlay for back/favorite buttons visibility
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 90.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Top Action Controls (Back & Favorite)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8.h,
          left: 16.w,
          right: 16.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                radius: 20.r,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                  onPressed: () => context.pop(),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    radius: 20.r,
                    child: IconButton(
                      icon: Icon(
                        state.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: state.isFavorite ? Colors.red : Colors.white,
                        size: 20.sp,
                      ),
                      onPressed: () async {
                        await context.read<FieldDetailsCubit>().toggleFavorite();
                        if (context.mounted) {
                          try {
                            context.read<FavoritesCubit>().loadFavorites(isRefresh: true);
                          } catch (_) {}
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Image Counter Badge & Dots Indicator
        Positioned(
          bottom: 16.h,
          left: 16.w,
          right: 16.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Page Dots Indicator
              Row(
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: state.currentImageIndex == index ? 20.w : 7.w,
                    height: 7.h,
                    decoration: BoxDecoration(
                      color: state.currentImageIndex == index ? AppColors.primary : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),

              // Image Count Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${state.currentImageIndex + 1} / ${images.length}',
                  style: AppTypography.small(color: Colors.white).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget 2: Title & Badges
  Widget _buildTitleAndBadges(FieldModel field, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                field.name,
                style: AppTypography.heading2(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            RatingBadge(rating: field.rating),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: [
            _badgeChip(field.fieldType, AppColors.primary, isDark),
            _badgeChip(field.grassType, Colors.orange, isDark),
            _badgeChip(field.isIndoor ? 'صالة مغطاة' : 'ملعب مكشوف', Colors.blue, isDark),
            if (field.isAvailableToday)
              _badgeChip('متاح اليوم', AppColors.success, isDark),
          ],
        ),
      ],
    );
  }

  Widget _badgeChip(String label, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.small(color: color).copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget: Address Row
  Widget _buildAddressRow(FieldModel field, bool isDark) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 18.sp, color: AppColors.primary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            field.address,
            style: AppTypography.body(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.greyLight,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            field.distance,
            style: AppTypography.caption(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Widget 3: Quick Action Bar
  Widget _buildQuickActionsRow(BuildContext context, FieldModel field, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.phone_outlined,
            label: 'صاحب الملعب',
            color: AppColors.primary,
            isDark: isDark,
            onTap: () {
              final phoneNum = field.phone ?? '01012345678';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('رقم الهاتف: $phoneNum'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _actionButton(
            icon: Icons.map_outlined,
            label: 'فتح الخريطة',
            color: Colors.blue,
            isDark: isDark,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('موقع الملعب: ${field.address}'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ),
        SizedBox(width: 10.w),
        _actionSquareButton(
          icon: Icons.share_outlined,
          isDark: isDark,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم نسخ رابط الملعب إلى الحافظة!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: color),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: AppTypography.caption(color: color).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionSquareButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.greyLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  // Widget 4: Description Section
  Widget _buildDescriptionSection(
    BuildContext context,
    FieldDetailsLoaded state,
    bool isDark,
  ) {
    final description = state.field.description;
    final isExpanded = state.isDescriptionExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'وصف الملعب',
          style: AppTypography.title(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          description,
          style: AppTypography.body(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          maxLines: isExpanded ? 100 : 3,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (description.length > 100)
          GestureDetector(
            onTap: () => context.read<FieldDetailsCubit>().toggleDescriptionExpand(),
            child: Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Text(
                isExpanded ? 'عرض أقل' : 'اقرأ المزيد',
                style: AppTypography.caption(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Widget 5: Facilities Section
  Widget _buildFacilitiesSection(FieldModel field, bool isDark) {
    final facilityMap = {
      'إضاءة ليلية': Icons.lightbulb_outline,
      'مواقف سيارات': Icons.local_parking,
      'دورات مياه': Icons.wc,
      'مقهى': Icons.coffee,
      'غرف تبديل': Icons.dry_cleaning_outlined,
      'غرف تبديل ملابس': Icons.checkroom,
      'تكييف هوائي': Icons.ac_unit,
      'مدرجات': Icons.stadium_outlined,
      'نجيل طبيعي': Icons.grass,
      'إضاءة كاشفة': Icons.flashlight_on_outlined,
    };

    final facilities = field.facilities.isNotEmpty
        ? field.facilities
        : ['إضاءة ليلية', 'مواقف سيارات', 'دورات مياه', 'مقهى', 'غرف تبديل'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المرافق والخدمات',
          style: AppTypography.title(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 14.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 0.95,
          ),
          itemCount: facilities.length,
          itemBuilder: (context, index) {
            final name = facilities[index];
            final icon = facilityMap[name] ?? Icons.check_circle_outline;
            return Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.greyLight,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Icon(icon, size: 18.sp, color: AppColors.primary),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    name,
                    style: AppTypography.small(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Widget 6: Map Preview Card
  Widget _buildMapCard(BuildContext context, FieldModel field, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الموقع الجغرافي',
              style: AppTypography.title(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              field.city,
              style: AppTypography.caption(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          height: 150.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: isDark ? AppColors.cardDark : AppColors.greyLight,
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=800'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Colors.black.withValues(alpha: 0.4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 36.sp, color: AppColors.primary),
                SizedBox(height: 6.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    field.address,
                    style: AppTypography.caption(color: Colors.white).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                SizedBox(height: 10.h),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('جارِ فتح خرائط جوجل: ${field.address}')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  ),
                  icon: Icon(Icons.directions, size: 16.sp, color: Colors.white),
                  label: Text('الاتجاهات في الخريطة', style: AppTypography.small(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget 7: Interactive Date Picker Strip
  Widget _buildDatePickerSection(
    BuildContext context,
    FieldDetailsLoaded state,
    List<DateTime> availableDates,
    bool isDark,
  ) {
    final selectedDateStr = state.selectedDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر تاريخ الحجز',
          style: AppTypography.title(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 80.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: availableDates.length,
            separatorBuilder: (context, index) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final dateObj = availableDates[index];
              final formattedKey = DateFormat('yyyy-MM-dd').format(dateObj);
              final dayName = _formatDayName(dateObj);
              final dayNum = dateObj.day.toString();
              final monthName = _formatMonthName(dateObj);
              final isSelected = formattedKey == selectedDateStr;

              return GestureDetector(
                onTap: () => context.read<FieldDetailsCubit>().selectDate(formattedKey),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70.w,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.cardDark : AppColors.greyLight),
                    borderRadius: BorderRadius.circular(16.r),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: AppTypography.small(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        dayNum,
                        style: AppTypography.body(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        monthName,
                        style: AppTypography.small(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.9)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ).copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget 8: Time Slots Grid
  Widget _buildTimeSlotsSection(
    BuildContext context,
    FieldDetailsLoaded state,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المواعيد المتاحة',
              style: AppTypography.title(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                _legendDot(AppColors.primary, 'متاح'),
                SizedBox(width: 8.w),
                _legendDot(AppColors.error, 'محجوز'),
              ],
            ),
          ],
        ),
        SizedBox(height: 14.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
            final isSelected = timeStr == state.selectedTimeSlot;

            Color bgColor;
            Color textColor;

            if (status == 'booked') {
              bgColor = isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.1);
              textColor = AppColors.error;
            } else if (isSelected) {
              bgColor = AppColors.primary;
              textColor = Colors.white;
            } else {
              bgColor = isDark ? AppColors.cardDark : AppColors.greyLight;
              textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            }

            return GestureDetector(
              onTap: status == 'booked'
                  ? null
                  : () => context.read<FieldDetailsCubit>().selectTimeSlot(timeStr),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: isSelected
                      ? Border.all(color: AppColors.primaryDark, width: 2)
                      : (status == 'booked' ? Border.all(color: AppColors.error.withValues(alpha: 0.3)) : null),
                ),
                alignment: Alignment.center,
                child: Text(
                  timeStr,
                  style: AppTypography.caption(color: textColor).copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: status == 'booked' ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
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

  // Widget 9: Reviews Section
  Widget _buildReviewsSection(FieldModel field, List<ReviewModel> reviews, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'التقييمات والآراء',
                  style: AppTypography.title(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '${reviews.length}',
                    style: AppTypography.small(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => _openAddEditReviewSheet(context, field),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.rate_review_outlined, size: 14.sp, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text(
                      'أضف تقييمك',
                      style: AppTypography.small(color: Colors.white).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Rating Overview Card
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.greyLight,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    field.rating.toStringAsFixed(1),
                    style: AppTypography.heading1(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        color: index < field.rating.floor() ? AppColors.accent : Colors.grey,
                        size: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'من 5 نقاط',
                    style: AppTypography.small(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: Column(
                  children: [
                    _ratingBar(5, 0.85, isDark),
                    _ratingBar(4, 0.10, isDark),
                    _ratingBar(3, 0.03, isDark),
                    _ratingBar(2, 0.01, isDark),
                    _ratingBar(1, 0.01, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Reviews List
        if (reviews.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: Text(
                'لا توجد تقييمات حتى الآن. كن أول من يقيّم هذا الملعب!',
                style: AppTypography.body(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final rev = reviews[index];
              return Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18.r,
                          backgroundImage: rev.userAvatar != null ? NetworkImage(rev.userAvatar!) : null,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                          child: rev.userAvatar == null
                              ? Text(
                                  rev.userName.isNotEmpty ? rev.userName[0] : 'م',
                                  style: AppTypography.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rev.userName,
                                style: AppTypography.body(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                rev.createdAt,
                                style: AppTypography.small(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RatingBadge(rating: rev.rating),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18.sp,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.iconGrey,
                          ),
                          onSelected: (val) {
                            if (val == 'edit') {
                              _openAddEditReviewSheet(context, field, rev);
                            } else if (val == 'delete') {
                              _confirmDeleteReview(context, rev.id);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 16.sp, color: AppColors.primary),
                                  SizedBox(width: 8.w),
                                  const Text('تعديل التقييم'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 16.sp, color: AppColors.error),
                                  SizedBox(width: 8.w),
                                  const Text('حذف التقييم', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      rev.comment,
                      style: AppTypography.body(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _openAddEditReviewSheet(BuildContext context, FieldModel field, [ReviewModel? existingReview]) {
    final cubit = context.read<FieldDetailsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return AddEditReviewBottomSheet(
          fieldId: field.id,
          existingReview: existingReview,
          onSubmit: (rating, comment) async {
            bool success;
            if (existingReview != null) {
              success = await cubit.editReview(
                reviewId: existingReview.id,
                rating: rating,
                comment: comment,
              );
            } else {
              success = await cubit.addReview(
                rating: rating,
                comment: comment,
              );
            }

            if (mounted && success) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(existingReview != null ? 'تم تعديل تقييمك بنجاح!' : 'تم إضافة تقييمك بنجاح!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          },
        );
      },
    );
  }

  void _confirmDeleteReview(BuildContext context, String reviewId) {
    final cubit = context.read<FieldDetailsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف التقييم'),
        content: const Text('هل أنت تأكد من رغبتك في حذف هذا التقييم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await cubit.deleteReview(reviewId);
              if (mounted && success) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف التقييم بنجاح'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _ratingBar(int star, double percent, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Text('$star', style: AppTypography.small(color: AppColors.textSecondaryLight)),
          SizedBox(width: 4.w),
          Icon(Icons.star, size: 10.sp, color: AppColors.accent),
          SizedBox(width: 6.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                color: AppColors.primary,
                minHeight: 6.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget 10: Related Fields Carousel
  Widget _buildRelatedFieldsSection(BuildContext context, List<FieldModel> related, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاعب مشابهة',
          style: AppTypography.title(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 180.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final rel = related[index];
              return GestureDetector(
                onTap: () => context.push('/field-details/${rel.id}'),
                child: Container(
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                        child: CachedNetworkImage(
                          imageUrl: rel.mainImage,
                          height: 100.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rel.name,
                              style: AppTypography.body(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ).copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${rel.pricePerHour.toInt()} ج.م / ساعة',
                                  style: AppTypography.small(color: AppColors.primary).copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                RatingBadge(rating: rel.rating),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget 11: Sticky Bottom Booking Bar
  Widget _buildStickyBottomBar(
    BuildContext context,
    FieldModel field,
    FieldDetailsLoaded state,
    bool isDark,
  ) {
    final selectedSlot = state.selectedTimeSlot ?? '18:00';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${field.pricePerHour.toInt()} ',
                          style: AppTypography.heading2(color: AppColors.primary).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'جنيه / ساعة',
                          style: AppTypography.body(color: AppColors.primary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12.sp, color: AppColors.textSecondaryLight),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            'الموعد المحدد: $selectedSlot',
                            style: AppTypography.small(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              PrimaryButton(
                title: 'احجز الآن',
                width: 150.w,
                onPressed: () {
                  context.push(
                    '/booking',
                    extra: {
                      'fieldId': field.id,
                      'fieldName': field.name,
                      'fieldAddress': field.address,
                      'fieldImage': field.mainImage,
                      'price': field.pricePerHour,
                      'initialDate': state.selectedDate,
                      'initialTimeSlot': selectedSlot,
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
