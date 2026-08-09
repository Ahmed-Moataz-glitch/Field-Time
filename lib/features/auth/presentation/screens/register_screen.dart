import 'package:field_time/app/router/app_router.dart';
import 'package:field_time/core/utils/app_dialogs.dart';
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final AuthCubit _authCubit;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  String _selectedRole = 'user'; // 'user' (Player) or 'owner' (Field Owner)

  @override
  void initState() {
    super.initState();
    _authCubit = context.read<AuthCubit>();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      await _authCubit.register(
        fullName: _nameController.text.trim(),
        email: email,
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
      );
      if (_authCubit.state is Authenticated) {
        await _authCubit.sendOtpForNewUser(email);
      }
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
        bloc: _authCubit,
        listenWhen: (previous, current) =>
            current is AuthLoading ||
            current is Authenticated ||
            current is AuthError,
        listener: (context, state) {
          if (state is AuthLoading) {
            AppDialogs.showLoadingDialog(context, title: 'جار إنشاء الحساب...');
          }
          if (state is Authenticated) {
            context.pop(); // Close loading dialog
            context.pushNamed(
              AppRouter.verifyEmailName,
              extra: _authCubit,
              queryParameters: {
                'email': _emailController.text.trim(),
              },
            );
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
                  Text(
                    '${l10n.register} ⚽',
                    style: AppTypography.heading1(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'أنشئ حسابك للبدء في حجز ملاعبك المفضلة',
                    style: AppTypography.body(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Account Type Selector (Player vs Field Owner)
                  Text(
                    'نوع الحساب',
                    style: AppTypography.caption(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _RoleCard(
                          l10n: l10n,
                          title: 'لاعب / حاجز',
                          icon: Icons.sports_soccer,
                          isSelected: _selectedRole == 'user',
                          onTap: () => setState(() => _selectedRole = 'user'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _RoleCard(
                          l10n: l10n,
                          title: 'صاحب ملعب',
                          icon: Icons.stadium_outlined,
                          isSelected: _selectedRole == 'owner',
                          onTap: () => setState(() => _selectedRole = 'owner'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Name Field
                  CustomTextField(
                    controller: _nameController,
                    hintText: l10n.fullName,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.iconGrey,
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'يرجى إدخال الاسم'
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    hintText: l10n.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.iconGrey,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'يرجى إدخال البريد';
                      }
                      if (!val.contains('@')) return 'بريد غير صالح';
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Phone Field
                  CustomTextField(
                    controller: _phoneController,
                    hintText: l10n.phone,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: AppColors.iconGrey,
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'يرجى إدخال رقم الهاتف'
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    hintText: l10n.password,
                    isPassword: _obscurePassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.iconGrey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.iconGrey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      if (val.trim().length < 6) {
                        return 'كلمة المرور لا تقل عن 6 أحرف';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.h),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        title: l10n.register,
                        isLoading: state is AuthLoading,
                        onPressed: _onRegisterPressed,
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${l10n.alreadyHaveAccount} ',
                        style: AppTypography.body(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          l10n.login,
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

class _RoleCard extends StatelessWidget {
  final AppLocalizations l10n;
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.l10n,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.greyBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isSelected ? AppColors.primary : AppColors.iconGrey,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style:
                  AppTypography.caption(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                  ).copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
