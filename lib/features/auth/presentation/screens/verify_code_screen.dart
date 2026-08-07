// ignore_for_file: use_build_context_synchronously
import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/utils/app_dialogs.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/core/widgets/timer_widget.dart';
import 'package:field_time/core/widgets/verify_code_widget.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyCodeScreen extends StatefulWidget {
  final AuthCubit? authCubit;
  final String? email;
  const VerifyCodeScreen({
    super.key,
    this.email,
    this.authCubit,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  AuthCubit get cubit => widget.authCubit ?? context.read<AuthCubit>();
  late PinInputController otpController;

  @override
  void initState() {
    super.initState();
    otpController = PinInputController();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.divider,
      appBar: AppBar(
        backgroundColor: AppColors.divider,
        title: Text('التحقق', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        bloc: widget.authCubit,
        listenWhen: (previous, current) =>
            current is SendingOtp ||
            current is OtpSent ||
            current is SendingOtpError ||
            current is OtpVerified ||
            current is VerifyingOtpError,
        listener: (context, state) {
          if (state is SendingOtp) {
            AppDialogs.showLoadingDialog(
              context,
              title: 'جار إعادة إرسال رمز التحقق...',
            );
          } else {
            Navigator.of(context, rootNavigator: true).pop();
          }
          if (state is OtpVerified) {
            context.pushNamed(
              AppRouter.resetPasswordName,
              extra: widget.authCubit,
            );
          }
          if (state is VerifyingOtpError) {
            AppDialogs.showSnackBar(
              context: context,
              message: state.message,
              isError: true,
            );
          }
          if (state is OtpSent) {
            AppDialogs.showSnackBar(context: context, message: state.message);
          }
          if (state is SendingOtpError) {
            AppDialogs.showSnackBar(
              context: context,
              message: state.message,
              isError: true,
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 36.h),
          child: Column(
            children: [
              Text(
                'يرجى إدخال عنوان البريد الإلكتروني الذي استخدمته عند إنشاء حسابك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyBorder,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Text.rich(
                overflow: TextOverflow.ellipsis,
                TextSpan(
                  text: "تم إرسال الرمز إلى ",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.surfaceDark,
                  ),
                  children: [
                    TextSpan(
                      text: widget.email ?? 'ahmedmoataz123@gmail.com',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: AppColors.surfaceDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.04),
              VerifyCodeWidget(pinController: otpController),
              SizedBox(height: size.height * 0.04),
              PrimaryButton(
                title: '',
                onPressed: () async {
                  // debugPrint('Verification code: ${verificationController.text}');
                  await cubit.validateOtp(
                    email: widget.email ?? '',
                    otp: otpController.text,
                  );
                },
              ),
              SizedBox(height: size.height * 0.02),
              Text.rich(
                TextSpan(
                  text: "لم تستلم الرمز؟ ",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.surfaceDark,
                  ),
                  children: [
                    TextSpan(
                      text: "إعادة إرسال الرمز",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        shadows: [
                          Shadow(
                            color: AppColors.primary,
                            blurRadius: 2,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await cubit.sendOtpForExistingUser(
                            widget.email ?? '',
                          );
                          // AppDialogs.showSnackBar(
                          //   context: context,
                          //   message: 'Code resent successfully',
                          // );
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),
              const TimerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
