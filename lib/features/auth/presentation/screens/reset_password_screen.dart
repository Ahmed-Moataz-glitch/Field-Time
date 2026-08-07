import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/utils/app_dialogs.dart';
import 'package:field_time/core/utils/app_toast.dart';
import 'package:field_time/core/widgets/custom_text_field.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/core/widgets/validator.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

class ResetPasswordScreen extends StatefulWidget {
  final AuthCubit? authCubit;
  const ResetPasswordScreen({super.key, this.authCubit});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  AuthCubit get cubit => widget.authCubit ?? context.read<AuthCubit>();
  final formKey = GlobalKey<FormState>();
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final token = SecureStorage.getToken();
    return Scaffold(
      backgroundColor: AppColors.divider,
      appBar: AppBar(
        backgroundColor: AppColors.divider,
        title: Text(
          "إعادة تعيين كلمة المرور",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        bloc: widget.authCubit,
        listenWhen: (previous, current) =>
            current is AuthLoading ||
            current is AuthSuccess || 
            current is AuthError,
        listener: (context, state) {
          if(state is AuthLoading){
            AppDialogs.showLoadingDialog(context, title: 'جار إعادة تعيين كلمة المرور...');
          }
          if (state is AuthSuccess) {
            context.pushNamed(AppRouter.successfulResetPasswordName);
          }
          if (state is AuthError) {
            context.pop();
            AppToast.showToast(
              context: context,
              title: 'خطأ',
              description: state.message,
              type: ToastificationType.error,
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
                "يرجى إدخال عنوان البريد الإلكتروني الذي استخدمته عند إنشاء حسابك",
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
                      "كلمة المرور الجديدة",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surfaceDark,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    CustomTextField(
                      isPassword: true,
                      controller: newPasswordController,
                      validator: Validator.validatePassword,
                      hintText: "أدخل كلمة المرور الجديدة",
                    ),
                    SizedBox(height: size.height * 0.04),
                    Text(
                      "تأكيد كلمة المرور",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surfaceDark,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    CustomTextField(
                      isPassword: true,
                      controller: confirmPasswordController,
                      validator: (value) => Validator.validateConfirmPassword(
                        value,
                        newPasswordController.text.trim(),
                      ),
                      hintText: "أكد كلمة المرور",
                    ),
                    SizedBox(height: size.height * 0.05),
                    PrimaryButton(
                      title: "إعادة تعيين كلمة المرور",
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await cubit.resetPassword(
                            newPasswordController.text.trim(),
                          );
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
