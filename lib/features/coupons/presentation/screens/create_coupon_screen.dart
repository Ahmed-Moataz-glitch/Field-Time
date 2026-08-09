import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/custom_text_field.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/features/coupons/presentation/cubit/coupon_management_cubit.dart';
import 'package:field_time/features/coupons/presentation/cubit/coupon_management_state.dart';

class CreateCouponScreen extends StatefulWidget {
  const CreateCouponScreen({super.key});

  @override
  State<CreateCouponScreen> createState() => _CreateCouponScreenState();
}

class _CreateCouponScreenState extends State<CreateCouponScreen> {
  late final CouponManagementCubit _couponManagementCubit;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _codeController;
  late final TextEditingController _valueController;
  late final TextEditingController _minAmountController;
  late final TextEditingController _limitController;

  String _selectedType = 'fixed'; // 'fixed', 'percentage', 'free'
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _couponManagementCubit = context.read<CouponManagementCubit>();
    _formKey = GlobalKey<FormState>();
    _codeController = TextEditingController();
    _valueController = TextEditingController();
    _minAmountController = TextEditingController(text: '0');
    _limitController = TextEditingController();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _codeController.dispose();
    _valueController.dispose();
    _minAmountController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.backgroundLight,
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.backgroundLight
                  : AppColors.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _expiresAt = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final code = _codeController.text.trim().toUpperCase();
    final double value = _selectedType == 'free'
        ? 100.0
        : (double.tryParse(_valueController.text.trim()) ?? 0.0);
    final double minAmount =
        double.tryParse(_minAmountController.text.trim()) ?? 0.0;
    final int? limit = int.tryParse(_limitController.text.trim());

    final result = await _couponManagementCubit.createCoupon(
      code: code,
      discountType: _selectedType,
      discountValue: value,
      minBookingAmount: minAmount,
      expiresAt: _expiresAt,
      usageLimit: limit,
    );

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إنشاء الكوبون ($code) بنجاح! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إنشاء كوبون جديد',
          style: AppTypography.heading3(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocListener<CouponManagementCubit, CouponManagementState>(
          listener: (context, state) {
            if (state is CouponManagementError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 16.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Coupon Code Input
                  Text(
                    'رمز الكوبون (Promo Code)',
                    style: AppTypography.title(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  CustomTextField(
                    controller: _codeController,
                    hintText: 'رمز الكوبون (مثال: SUMMER50, FREEPASS)',
                    prefixIcon: const Icon(Icons.confirmation_number_outlined),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'يرجى إدخال رمز الكوبون';
                      }
                      if (val.trim().length < 3) {
                        return 'كود الكوبون لا يقل عن 3 أحرف';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 24.h),

                  // 2. Discount Type Selection
                  Text(
                    'نوع الخصم',
                    style: AppTypography.title(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 10.w,
                    children: [
                      ChoiceChip(
                        label: const Text('مبلغ ثابت (ج.م)'),
                        selected: _selectedType == 'fixed',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _selectedType == 'fixed' ? Colors.white : null,
                        ),
                        onSelected: (val) =>
                            setState(() => _selectedType = 'fixed'),
                      ),
                      ChoiceChip(
                        label: const Text('نسبة مئوية (%)'),
                        selected: _selectedType == 'percentage',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _selectedType == 'percentage'
                              ? Colors.white
                              : null,
                        ),
                        onSelected: (val) =>
                            setState(() => _selectedType = 'percentage'),
                      ),
                      ChoiceChip(
                        label: const Text('حجز مجاني (100%) 🎉'),
                        selected: _selectedType == 'free',
                        selectedColor: AppColors.success,
                        labelStyle: TextStyle(
                          color: _selectedType == 'free' ? Colors.white : null,
                        ),
                        onSelected: (val) =>
                            setState(() => _selectedType = 'free'),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // 3. Value & Min Booking Amount
                  if (_selectedType != 'free') ...[
                    Text(
                      _selectedType == 'fixed'
                          ? 'قيمة الخصم بالجنيه'
                          : 'نسبة الخصم (%)',
                      style: AppTypography.title(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      controller: _valueController,
                      hintText: _selectedType == 'fixed'
                          ? 'مثال: 50'
                          : 'مثال: 25',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(
                        _selectedType == 'fixed'
                            ? Icons.attach_money
                            : Icons.percent,
                      ),
                      validator: (val) {
                        if (_selectedType == 'free') return null;
                        if (val == null || val.trim().isEmpty) {
                          return 'يرجى إدخال قيمة الخصم';
                        }
                        final numVal = double.tryParse(val.trim());
                        if (numVal == null || numVal <= 0) {
                          return 'قيمة غير صالحة';
                        }
                        if (_selectedType == 'percentage' && numVal > 100) {
                          return 'النسبة لا تزيد عن 100%';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                  ],

                  Text(
                    'الحد الأدنى لقيمة الحجز (ج.م)',
                    style: AppTypography.title(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  CustomTextField(
                    controller: _minAmountController,
                    hintText: '0 تعني بدون حد أدنى',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 4. Expiration Date Selection
                  Text(
                    'تاريخ انتهاء الكوبون',
                    style: AppTypography.title(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  InkWell(
                    onTap: _pickExpiryDate,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'ينتهي بتاريخ: ${DateFormat('yyyy-MM-dd').format(_expiresAt)}',
                              style: AppTypography.body(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(
                            Icons.edit_calendar,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 5. Usage Limit (Max Redemptions)
                  Text(
                    'الحد الأقصى لعدد مرات الاستخدام (اختياري)',
                    style: AppTypography.title(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  CustomTextField(
                    controller: _limitController,
                    hintText: 'اتركه فارغاً لاستخدام غير محدود',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.people_outline),
                  ),

                  SizedBox(height: 32.h),

                  // 6. Submit Button
                  PrimaryButton(
                    title: 'حفظ وإنشاء الكوبون',
                    isLoading: _isLoading,
                    onPressed: _submitForm,
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
