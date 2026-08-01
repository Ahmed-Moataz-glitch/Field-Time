import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/localization/locale_cubit.dart';
import 'package:field_time/core/widgets/custom_text_field.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:field_time/features/booking/presentation/cubit/booking_state.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class BookingScreen extends StatefulWidget {
  final String fieldId;
  final String fieldName;
  final String fieldAddress;
  final String fieldImage;
  final double price;
  final String? initialDate;
  final String? initialTimeSlot;

  const BookingScreen({
    super.key,
    required this.fieldId,
    required this.fieldName,
    required this.fieldAddress,
    required this.fieldImage,
    required this.price,
    this.initialDate,
    this.initialTimeSlot,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late String _selectedDate;
  late String _selectedTimeSlot;
  final TextEditingController _couponController = TextEditingController();

  double _discountAmount = 0.0;
  bool _isCouponApplied = false;
  bool _isLoading = false;

  final List<String> _availableSlots = const [
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
    '23:00',
  ];

  @override
  void initState() {
    super.initState();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedDate = widget.initialDate ?? todayStr;
    _selectedTimeSlot = widget.initialTimeSlot ?? '19:00';
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  List<DateTime> _getAvailableDates() {
    final now = DateTime.now();
    return List.generate(7, (index) => now.add(Duration(days: index)));
  }

  String _formatDayName(DateTime date, bool isArabic) {
    final arabicDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    final englishDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final dayIndex = date.weekday % 7;
    return isArabic ? arabicDays[dayIndex] : englishDays[dayIndex];
  }

  void _applyCoupon(bool isArabic) {
    final code = _couponController.text.trim().toUpperCase();
    if (code == 'FIELD20' || code == 'OFFER50') {
      setState(() {
        _discountAmount = 50.0;
        _isCouponApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'تم تطبيق خصم 50 جنيه بنجاح! 🎉' : '50 EGP discount applied successfully! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'كوبون غير صالح أو منتهي الصلاحية' : 'Invalid or expired promo code'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleConfirmBooking(bool isArabic) async {
    setState(() => _isLoading = true);

    final endHour = int.parse(_selectedTimeSlot.split(':')[0]) + 1;
    final timeSlotFormatted = '$_selectedTimeSlot - ${endHour.toString().padLeft(2, '0')}:00';
    final finalPrice = (widget.price - _discountAmount).clamp(0.0, 10000.0);

    final booking = await context.read<BookingCubit>().createBooking(
          fieldId: widget.fieldId,
          fieldName: widget.fieldName,
          fieldAddress: widget.fieldAddress,
          fieldImage: widget.fieldImage,
          date: _selectedDate,
          timeSlot: timeSlotFormatted,
          price: finalPrice,
        );

    setState(() => _isLoading = false);

    if (booking != null && mounted) {
      context.push('/booking-success');
    } else if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  isArabic ? 'تنبيه الحجز' : 'Booking Alert',
                  style: AppTypography.title(color: AppColors.error).copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Text(
            isArabic
                ? 'هذا الموعد ($timeSlotFormatted بتاريخ $_selectedDate) محجوز بالفعل! يرجى اختيار موعد آخر.'
                : 'The slot ($timeSlotFormatted on $_selectedDate) is already booked! Please select another time.',
            style: AppTypography.body(color: AppColors.textPrimaryLight),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(isArabic ? 'تغيير الموعد' : 'Change Slot', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isArabic = context.watch<LocaleCubit>().state.isArabic;

    final dates = _getAvailableDates();
    final totalPrice = (widget.price - _discountAmount).clamp(0.0, 10000.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.confirmBooking ?? (isArabic ? 'استكمال الحجز الفوري' : 'Instant Booking Confirmation'),
          style: AppTypography.heading3(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingDuplicateError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Field Summary Card
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: CachedNetworkImage(
                          imageUrl: widget.fieldImage,
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
                            Text(
                              widget.fieldName,
                              style: AppTypography.title(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ).copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 14.sp, color: AppColors.primary),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    widget.fieldAddress,
                                    style: AppTypography.small(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              isArabic ? '${widget.price.toInt()} جنيه / ساعة' : '${widget.price.toInt()} EGP / hr',
                              style: AppTypography.caption(color: AppColors.primary).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // 2. Select Date Strip
                Text(
                  l10n?.chooseDate ?? (isArabic ? 'اختر تاريخ الحجز' : 'Select Booking Date'),
                  style: AppTypography.title(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 72.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    separatorBuilder: (context, index) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      final dateObj = dates[index];
                      final dateKey = DateFormat('yyyy-MM-dd').format(dateObj);
                      final isSelected = dateKey == _selectedDate;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDate = dateKey),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 68.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.cardDark : AppColors.greyLight),
                            borderRadius: BorderRadius.circular(16.r),
                            border: isSelected ? Border.all(color: AppColors.primaryDark, width: 2) : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatDayName(dateObj, isArabic),
                                style: AppTypography.small(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${dateObj.day}',
                                style: AppTypography.body(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 24.h),

                // 3. Select Time Slot Grid
                Text(
                  l10n?.chooseTime ?? (isArabic ? 'اختر الموعد' : 'Select Time Slot'),
                  style: AppTypography.title(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: _availableSlots.length,
                  itemBuilder: (context, index) {
                    final slot = _availableSlots[index];
                    final isSelected = slot == _selectedTimeSlot;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedTimeSlot = slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.cardDark : AppColors.greyLight),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          slot,
                          style: AppTypography.caption(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 24.h),

                // 4. Promo Coupon Box
                Text(
                  isArabic ? 'كوبون الخصم' : 'Promo Code',
                  style: AppTypography.title(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _couponController,
                        hintText: isArabic ? 'أدخل رمز الخصم (FIELD20)' : 'Enter code (e.g. FIELD20)',
                        prefixIcon: const Icon(Icons.confirmation_number_outlined),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCouponApplied ? null : () => _applyCoupon(isArabic),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text(
                          _isCouponApplied
                              ? (isArabic ? 'تم' : 'Applied')
                              : (isArabic ? 'تطبيق' : 'Apply'),
                          style: AppTypography.caption(color: Colors.white).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

                // 5. Price Breakdown Card
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      _priceRow(
                        isArabic ? 'سعر حجز الملعب' : 'Field Rental Price',
                        isArabic ? '${widget.price.toInt()} ج.م' : '${widget.price.toInt()} EGP',
                        isDark,
                      ),
                      if (_discountAmount > 0) ...[
                        SizedBox(height: 8.h),
                        _priceRow(
                          isArabic ? 'خصم الكوبون' : 'Coupon Discount',
                          isArabic ? '-${_discountAmount.toInt()} ج.م' : '-${_discountAmount.toInt()} EGP',
                          isDark,
                          isDiscount: true,
                        ),
                      ],
                      SizedBox(height: 8.h),
                      _priceRow(
                        isArabic ? 'رسوم الخدمة' : 'Service Fee',
                        isArabic ? 'مجاناً' : 'Free',
                        isDark,
                        isFree: true,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Divider(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isArabic ? 'المبلغ الإجمالي' : 'Total Amount',
                              style: AppTypography.title(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ).copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            isArabic ? '${totalPrice.toInt()} جنيه' : '${totalPrice.toInt()} EGP',
                            style: AppTypography.heading2(color: AppColors.primary).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // 6. Confirm Booking CTA Button
                PrimaryButton(
                  title: isArabic ? 'تأكيد الحجز الفوري' : 'Confirm Booking Now',
                  isLoading: _isLoading,
                  onPressed: () => _handleConfirmBooking(isArabic),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, bool isDark, {bool isDiscount = false, bool isFree = false}) {
    Color valueColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    if (isDiscount) valueColor = AppColors.success;
    if (isFree) valueColor = AppColors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.body(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: AppTypography.body(color: valueColor).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
