// ignore_for_file: use_build_context_synchronously
import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/utils/app_dialogs.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/core/widgets/verify_code_widget.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyEmailScreen extends StatefulWidget {
  final AuthCubit? authCubit;
  final String? email;
  const VerifyEmailScreen({
    super.key,
    this.email,
    this.authCubit,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
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
        title: Text('التحقق', style: TextStyle(fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        bloc: widget.authCubit,
        listenWhen: (previous, current) =>
            current is SendingOtp ||
            current is OtpVerified ||
            current is VerifyingOtpError ||
            current is OtpSent ||
            current is SendingOtpError,
        listener: (context, state) {
          if (state is SendingOtp) {
            AppDialogs.showLoadingDialog(
              context,
              title: "جارٍ إرسال رمز التحقق...",
            );
          } else {
            Navigator.of(context, rootNavigator: true).pop();
          }
          if (state is OtpVerified) {
            context.pushReplacementNamed(
              AppRouter.loginName,
            );
          }
          if (state is VerifyingOtpError) {
            debugPrint(state.message);
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
          child: Column(
            children: [
              Text(
                "يرجى إدخال عنوان البريد الإلكتروني الذي استخدمته عند إنشاء حسابك",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greyBorder,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Text.rich(
                overflow: TextOverflow.ellipsis,
                TextSpan(
                  text: "تم إرسال الرمز إلى ",
                  style: TextStyle(fontSize: 16.sp, color: AppColors.surfaceDark),
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
                title: "تحقق",
                onPressed: () async {
                  // debugPrint('Verification code: ${verificationController.text}');
                  await cubit.validateOtp(
                    email: widget.email ?? '',
                    otp: otpController.text.trim(),
                  );
                },
              ),
              SizedBox(height: size.height * 0.02),
              Text.rich(
                TextSpan(
                  text: "لم تستلم الرمز؟ ",
                  style: TextStyle(fontSize: 16.sp, color: AppColors.surfaceDark),
                  children: [
                    TextSpan(
                      text: "إعادة إرسال الرمز",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await cubit.sendOtpForNewUser(
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
            ],
          ),
        ),
      ),
    );
  }
}
