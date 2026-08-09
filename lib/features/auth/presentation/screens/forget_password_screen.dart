import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/utils/app_dialogs.dart';
import 'package:field_time/core/widgets/custom_text_field.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/core/widgets/validator.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ForgetPasswordScreen extends StatefulWidget {
  final AuthCubit? authCubit;
  const ForgetPasswordScreen({super.key, this.authCubit});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  AuthCubit get cubit => widget.authCubit ?? context.read<AuthCubit>();
  late final GlobalKey<FormState> formKey;
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    formKey.currentState?.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColors.divider,
      appBar: AppBar(
        backgroundColor: AppColors.divider,
        title: Text(
          'نسيت كلمة المرور',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        bloc: widget.authCubit,
        listenWhen: (previous, current) =>
            current is SendingOtp ||
            current is OtpSent ||
            current is SendingOtpError,
        listener: (context, state) {
          if (state is SendingOtp) {
            AppDialogs.showLoadingDialog(
              context,
              title: 'جار إرسال رمز التحقق...',
            );
          } else {
            context.pop();
          }
          if (state is OtpSent) {
            context.pushNamed(
              AppRouter.verifyCodeName,
              extra: widget.authCubit,
              queryParameters: {
                'email': emailController.text.trim(),
              },
            );
          }
          if (state is SendingOtpError) {
            debugPrint(state.message);
            AppDialogs.showSnackBar(
              context: context,
              message: state.message,
              isError: true,
            );
          }
        },
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            top: 36.h,
            right: 16.w,
            left: 16.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
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
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الايميل',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.surfaceDark,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    CustomTextField(
                      controller: emailController,
                      validator: Validator.validateEmail,
                      hintText: 'name@example.com',
                    ),
                    SizedBox(height: size.height * 0.05),
                    PrimaryButton(
                      title: 'التالي',
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await cubit.sendOtpForExistingUser(
                            emailController.text.trim(),
                          );
                          // AppDialogs.showSnackBar(
                          //   context: context,
                          //   message: 'Code is sent to email',
                          //   isError: true,
                          // );
                        }
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
