import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:field_time/features/profile/presentation/cubit/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الملف الشخصي',
          style: AppTypography.heading3(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final user = (state is ProfileLoaded) ? state.user : null;
              final name = user?.fullName ?? 'أحمد محمد';
              final phone = user?.phone ?? '01012345678';
              final avatar = user?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400';

              return Column(
                children: [
                  SizedBox(height: 12.h),
                  // Avatar Header
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 3.w),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: avatar,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    name,
                    style: AppTypography.heading3(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    phone,
                    style: AppTypography.caption(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  // Options List Container
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildOptionTile(
                          icon: Icons.person_outline,
                          title: 'المعلومات الشخصية',
                          onTap: () {},
                          isDark: isDark,
                        ),
                        const Divider(height: 1, color: AppColors.greyBorder),
                        _buildOptionTile(
                          icon: Icons.credit_card_outlined,
                          title: 'طرق الدفع',
                          onTap: () {},
                          isDark: isDark,
                        ),
                        const Divider(height: 1, color: AppColors.greyBorder),
                        _buildOptionTile(
                          icon: Icons.location_on_outlined,
                          title: 'العناوين المحفوظة',
                          onTap: () {},
                          isDark: isDark,
                        ),
                        const Divider(height: 1, color: AppColors.greyBorder),
                        _buildOptionTile(
                          icon: Icons.favorite_border,
                          title: 'المفضلة',
                          onTap: () {},
                          isDark: isDark,
                        ),
                        const Divider(height: 1, color: AppColors.greyBorder),
                        _buildOptionTile(
                          icon: Icons.notifications_none_outlined,
                          title: 'الإشعارات',
                          onTap: () {},
                          isDark: isDark,
                        ),
                        const Divider(height: 1, color: AppColors.greyBorder),
                        _buildOptionTile(
                          icon: Icons.help_outline,
                          title: 'الدعم والمساعدة',
                          onTap: () {},
                          isDark: isDark,
                        ),
                        const Divider(height: 1, color: AppColors.greyBorder),
                        _buildOptionTile(
                          icon: Icons.logout,
                          title: 'تسجيل الخروج',
                          textColor: AppColors.error,
                          iconColor: AppColors.error,
                          onTap: () {
                            context.read<AuthCubit>().logout();
                            context.go('/welcome');
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        size: 22.sp,
      ),
      title: Text(
        title,
        style: AppTypography.body(
          color: textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ).copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: iconColor ?? AppColors.iconGrey,
      ),
    );
  }
}
