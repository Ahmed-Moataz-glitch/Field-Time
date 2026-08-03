import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/app_image.dart';
import 'package:field_time/core/localization/locale_cubit.dart';
import 'package:field_time/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:field_time/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:field_time/features/profile/presentation/cubit/profile_state.dart';
import 'package:field_time/features/owner_dashboard/presentation/widgets/owner_password_dialog.dart';
import 'package:field_time/features/profile/presentation/widgets/change_avatar_sheet.dart';
import 'package:field_time/features/profile/presentation/widgets/change_password_sheet.dart';
import 'package:field_time/features/profile/presentation/widgets/edit_profile_sheet.dart';
import 'package:field_time/features/profile/presentation/widgets/settings_sheet.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

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

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => const SettingsSheet(),
    );
  }

  void _showEditProfileSheet(BuildContext context, String name, String phone, String city) {
    final cubit = context.read<ProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final isArabic = context.read<LocaleCubit>().state.isArabic;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => EditProfileSheet(
        currentName: name,
        currentPhone: phone,
        currentCity: city,
        onSubmit: (newName, newPhone, newCity) async {
          final success = await cubit.updateProfile(
            fullName: newName,
            phone: newPhone,
            city: newCity,
          );
          if (success) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(isArabic ? 'تم تحديث البيانات الشخصية بنجاح!' : 'Profile updated successfully!'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _showChangeAvatarSheet(BuildContext context, String currentAvatar) {
    final cubit = context.read<ProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final isArabic = context.read<LocaleCubit>().state.isArabic;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => ChangeAvatarSheet(
        currentAvatar: currentAvatar,
        onSelected: (newAvatarUrl) async {
          final success = await cubit.updateAvatar(newAvatarUrl);
          if (success) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(isArabic ? 'تم تحديث الصورة الشخصية بنجاح!' : 'Avatar updated successfully!'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final isArabic = context.read<LocaleCubit>().state.isArabic;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => ChangePasswordSheet(
        onSubmit: (currentPassword, newPassword) async {
          final success = await cubit.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
          if (success) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(isArabic ? 'تم تغيير كلمة المرور بنجاح!' : 'Password changed successfully!'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isArabic = context.read<LocaleCubit>().state.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.profile ?? (isArabic ? 'الملف الشخصي' : 'Profile'),
          style: AppTypography.heading3(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final user = (state is ProfileLoaded) ? state.user : null;
              final name = user?.fullName ?? (isArabic ? 'أحمد محمد' : 'Ahmed Mohamed');
              final phone = user?.phone ?? '01012345678';
              final city = user?.city ?? (isArabic ? 'القاهرة' : 'Cairo');
              final avatar = user?.avatarUrl ??
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400';

              return Column(
                children: [
                  SizedBox(height: 12.h),
                  // Avatar Header
                  Center(
                    child: GestureDetector(
                      onTap: () => _showChangeAvatarSheet(context, avatar),
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
                              child: AppImage(
                                imagePath: avatar,
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
                    '$phone • $city',
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
                          icon: Icons.storefront_outlined,
                          title: isArabic ? 'لوحة تحكم صاحب الملعب' : 'Field Owner Dashboard',
                          textColor: AppColors.primary,
                          iconColor: AppColors.primary,
                          onTap: () async {
                            final authenticated = await OwnerPasswordDialog.show(context);
                            if (authenticated && context.mounted) {
                              context.push('/owner-dashboard');
                            }
                          },
                          isDark: isDark,
                        ),
                        const Divider(height: 1, color: AppColors.greyBorder),
                        _buildOptionTile(
                          icon: Icons.person_outline,
                          title: isArabic ? 'المعلومات الشخصية' : 'Personal Information',
                          onTap: () => _showEditProfileSheet(context, name, phone, city),
                          isDark: isDark,
                        ),
                        const Divider(height: 1, color: AppColors.greyBorder),
                        _buildOptionTile(
                          icon: Icons.lock_outline_rounded,
                          title: isArabic ? 'تغيير كلمة المرور' : 'Change Password',
                          onTap: () => _showChangePasswordSheet(context),
                          isDark: isDark,
                        ),
                        const Divider(height: 1, color: AppColors.greyBorder),
                        _buildOptionTile(
                          icon: Icons.notifications_none_outlined,
                          title: l10n?.notifications ?? (isArabic ? 'الإشعارات' : 'Notifications'),
                          onTap: () => context.push('/notifications'),
                          isDark: isDark,
                        ),
                        const Divider(height: 1, color: AppColors.greyBorder),
                        _buildOptionTile(
                          icon: Icons.settings_outlined,
                          title: l10n?.settings ?? (isArabic ? 'الإعدادات والتفضيلات' : 'Settings & Preferences'),
                          onTap: () => _showSettingsSheet(context),
                          isDark: isDark,
                        ),
                        const Divider(height: 1, color: AppColors.greyBorder),
                        _buildOptionTile(
                          icon: Icons.logout,
                          title: l10n?.logout ?? (isArabic ? 'تسجيل الخروج' : 'Sign Out'),
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
