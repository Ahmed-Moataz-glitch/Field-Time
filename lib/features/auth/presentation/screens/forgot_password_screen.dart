import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/custom_text_field.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1; // 1: Email Input, 2: OTP Verification, 3: New Password

  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _currentOtpCode {
    return _otpControllers.map((c) => c.text.trim()).join();
  }

  void _onSendOtpPressed() {
    if (_emailFormKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().sendResetOtp(_emailController.text.trim());
    }
  }

  void _onVerifyOtpPressed() {
    final otp = _currentOtpCode;
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رمز التحقق المكون من 6 أرقام'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    context.read<AuthCubit>().verifyResetOtp(
          email: _emailController.text.trim(),
          otp: otp,
        );
  }

  void _onUpdatePasswordPressed() {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().confirmNewPassword(_newPasswordController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _step == 1
              ? 'نسيت كلمة المرور'
              : _step == 2
                  ? 'رمز التحقق OTP'
                  : 'كلمة مرور جديدة',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (_step > 1) {
              setState(() => _step--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetOtpSent) {
            setState(() => _step = 2);
            _startResendTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم إرسال رمز التحقق OTP إلى ${state.email}'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is PasswordResetOtpVerified) {
            setState(() => _step = 3);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم التحقق من الرمز بنجاح! يرجى تعيين كلمة مرور جديدة.'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث كلمة المرور بنجاح! يمكنك الآن تسجيل الدخول.'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/login');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _step == 1
                  ? _buildStep1EmailInput(isDark)
                  : _step == 2
                      ? _buildStep2OtpVerification(isDark)
                      : _buildStep3NewPassword(isDark),
            ),
          ),
        ),
      ),
    );
  }

  /// Step 1: Email Input View
  Widget _buildStep1EmailInput(bool isDark) {
    return Form(
      key: _emailFormKey,
      child: Column(
        key: const ValueKey(1),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Text(
            'إعادة تعيين كلمة المرور 🔐',
            style: AppTypography.heading2(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'أدخل البريد الإلكتروني المسجل حسابك به وستصلك رسالة تحتوي على رمز تحقق (OTP) مكون من 6 أرقام.',
            style: AppTypography.body(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 36.h),
          CustomTextField(
            controller: _emailController,
            hintText: 'البريد الإلكتروني',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.iconGrey),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'يرجى إدخال البريد الإلكتروني';
              }
              if (!val.contains('@') || !val.contains('.')) {
                return 'يرجى إدخال بريد إلكتروني صحيح';
              }
              return null;
            },
          ),
          SizedBox(height: 32.h),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return PrimaryButton(
                title: 'إرسال رمز التحقق (OTP)',
                isLoading: state is AuthLoading,
                onPressed: _onSendOtpPressed,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Step 2: 6-Digit OTP Verification View
  Widget _buildStep2OtpVerification(bool isDark) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        Text(
          'رمز التحقق OTP 🔑',
          style: AppTypography.heading2(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'تم إرسال رمز مكون من 6 أرقام إلى ${_emailController.text.trim()}',
          style: AppTypography.body(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 36.h),

        // 6 Single-Digit Fields
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 46.w,
                height: 56.h,
                child: TextFormField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: AppTypography.heading3(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : AppColors.greyLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      if (index < 5) {
                        _otpFocusNodes[index + 1].requestFocus();
                      } else {
                        _otpFocusNodes[index].unfocus();
                      }
                    } else if (index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ),
        ),

        SizedBox(height: 24.h),

        // Resend Timer Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'لم يصلك الرمز؟ ',
              style: AppTypography.caption(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            _resendCountdown > 0
                ? Text(
                    'إعادة الإرسال بعد $_resendCountdown ثانية',
                    style: AppTypography.caption(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : TextButton(
                    onPressed: () {
                      _startResendTimer();
                      context.read<AuthCubit>().sendResetOtp(_emailController.text.trim());
                    },
                    child: Text(
                      'إعادة إرسال الرمز',
                      style: AppTypography.caption(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),

        SizedBox(height: 32.h),

        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return PrimaryButton(
              title: 'تأكيد الرمز',
              isLoading: state is AuthLoading,
              onPressed: _onVerifyOtpPressed,
            );
          },
        ),
      ],
    );
  }

  /// Step 3: Set New Password View
  Widget _buildStep3NewPassword(bool isDark) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        key: const ValueKey(3),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Text(
            'تعيين كلمة مرور جديدة 🔒',
            style: AppTypography.heading2(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'أدخل كلمة المرور الجديدة وتأكد من تذكرها جيداً للتمكن من تسجيل الدخول.',
            style: AppTypography.body(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 32.h),

          CustomTextField(
            controller: _newPasswordController,
            hintText: 'كلمة المرور الجديدة',
            isPassword: _obscureNewPass,
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.iconGrey),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.iconGrey,
              ),
              onPressed: () => setState(() => _obscureNewPass = !_obscureNewPass),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'يرجى إدخال كلمة المرور الجديدة';
              }
              if (val.trim().length < 6) {
                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          CustomTextField(
            controller: _confirmPasswordController,
            hintText: 'تأكيد كلمة المرور الجديدة',
            isPassword: _obscureConfirmPass,
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.iconGrey),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.iconGrey,
              ),
              onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'يرجى تأكيد كلمة المرور الجديدة';
              }
              if (val.trim() != _newPasswordController.text.trim()) {
                return 'كلمتا المرور غير متطابقتين';
              }
              return null;
            },
          ),

          SizedBox(height: 32.h),

          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return PrimaryButton(
                title: 'تحديث كلمة المرور',
                isLoading: state is AuthLoading,
                onPressed: _onUpdatePasswordPressed,
              );
            },
          ),
        ],
      ),
    );
  }
}
