import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/features/booking/presentation/screens/my_bookings_screen.dart';
import 'package:field_time/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:field_time/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:field_time/features/home/presentation/screens/home_screen.dart';
import 'package:field_time/features/profile/presentation/screens/profile_screen.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class AppSection extends StatefulWidget {
  final int initialIndex;

  const AppSection({super.key, this.initialIndex = 0});

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
    Icons.home_rounded,
    Icons.calendar_today_rounded,
    Icons.favorite_rounded,
    Icons.person_rounded,
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

    final navBgColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final unselectedColor = isDark ? AppColors.textSecondaryDark : AppColors.iconGrey;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: AnimatedBottomNavigationBar.builder(
            itemCount: _pages.length,
            activeIndex: _currentIndex,
            height: 64.h,
            gapLocation: GapLocation.none,
            notchSmoothness: NotchSmoothness.smoothEdge,
            elevation: 0,
            backgroundColor: navBgColor,
            splashColor: AppColors.primary.withValues(alpha: 0.15),
            splashSpeedInMilliseconds: 300,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              if (index == 2) {
                try {
                  context.read<FavoritesCubit>().loadFavorites(isRefresh: true);
                } catch (_) {}
              }
            },
            tabBuilder: (index, isActive) {
              final activeColor = AppColors.primary;
              final color = isActive ? activeColor : unselectedColor;

              return SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Active Top Indicator Pill
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: 3.h,
                      width: isActive ? 20.w : 0.w,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(2.r),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                    ),
                    const Spacer(),

                    // Icon with scale micro-animation
                    AnimatedScale(
                      scale: isActive ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        isActive ? _filledIcons[index] : _outlinedIcons[index],
                        size: 22.sp,
                        color: color,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Label with font weight transition
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: color,
                        fontSize: 11.sp,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      ),
                      child: Text(
                        labels[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
