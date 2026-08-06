import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/core/utils/app_assets.dart';
import 'package:field_time/core/utils/app_dialogs.dart';
import 'package:field_time/core/utils/get_it.dart';
import 'package:field_time/core/widgets/secondary_outlined_button.dart';
import 'package:field_time/core/widgets/validator.dart';
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
import 'package:field_time/l10n/generated/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthCubit _authCubit;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _authCubit.close();
    _formKey.currentState?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _authCubit.loginWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            AppDialogs.showLoadingDialog(context, title: 'جار تسجيل الدخول...');
          }
          if (state is LoginWithGoogleSuccess) {
            context.pushReplacementNamed(AppRouter.appSectionName);
          }
          if (state is LoginWithGoogleError) {
            AppDialogs.showSnackBar(
              context: context,
              message: state.message,
              isError: true,
            );
          }
          if (state is Authenticated) {
            context.pop(); // Close the loading dialog
            context.pushReplacementNamed(AppRouter.appSectionName);
          } else if (state is AuthError) {
            context.pop(); // Close the loading dialog
            AppDialogs.showSnackBar(
              context: context,
              message: state.message,
              isError: true,
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    '${l10n.login} 👋',
                    style: AppTypography.heading1(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'مرحباً بك مجدداً، أدخل بياناتك للمتابعة',
                    style: AppTypography.body(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 36.h),
                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    hintText: l10n.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.iconGrey,
                    ),
                    validator: Validator.validateEmail,
                  ),
                  SizedBox(height: 16.h),
                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    hintText: l10n.password,
                    isPassword: true,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.iconGrey,
                    ),
                    validator: Validator.validatePassword,
                  ),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => context.pushNamed(
                        AppRouter.forgetPasswordName,
                        extra: _authCubit,
                      ),
                      child: Text(
                        l10n.forgotPassword,
                        style: AppTypography.caption(color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        title: l10n.login,
                        isLoading: state is AuthLoading,
                        onPressed: _onLoginPressed,
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return SecondaryOutlinedButton(
                        title: 'تسجيل الدخول باستخدام جوجل',
                        icon: AppAssets.googleIcon,
                        isLoading: state is LoginWithGoogleLoading,
                        onPressed: () async {
                          await _authCubit.loginWithGoogle();
                        },
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${l10n.dontHaveAccount} ',
                        style: AppTypography.body(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            context.pushReplacementNamed(AppRouter.registerName),
                        child: Text(
                          l10n.register,
                          style: AppTypography.body(
                            color: AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
