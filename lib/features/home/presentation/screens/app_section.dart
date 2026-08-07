import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/features/booking/presentation/screens/my_bookings_screen.dart';
import 'package:field_time/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:field_time/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:field_time/features/home/presentation/screens/home_screen.dart';
import 'package:field_time/features/profile/presentation/screens/profile_screen.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class AppSection extends StatefulWidget {
  final int initialIndex;

  const AppSection({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AppSection> createState() => _AppSectionState();
}

class _AppSectionState extends State<AppSection> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    MyBookingsScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  final List<IconData> _outlinedIcons = const [
    Icons.home_outlined,
    Icons.calendar_today_outlined,
    Icons.favorite_border,
    Icons.person_outline,
  ];

  final List<IconData> _filledIcons = const [
    Icons.home,
    Icons.calendar_today,
    Icons.favorite,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n?.home ?? 'الرئيسية',
      l10n?.bookings ?? 'حجوزاتي',
      l10n?.favorites ?? 'المفضلة',
      l10n?.profile ?? 'الملف الشخصي',
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _pages.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive
              ? AppColors.primary
              : (isDark ? AppColors.textSecondaryDark : AppColors.iconGrey);

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? _filledIcons[index] : _outlinedIcons[index],
                size: 24.r,
                color: color,
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.small(color: color).copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11.sp,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          );
        },
        activeIndex: _currentIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 20,
        rightCornerRadius: 20,
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        height: 68.h,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        shadow: BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 2) {
            context.read<FavoritesCubit>().loadFavorites(isRefresh: true);
          }
        },
      ),
    );
  }
}
