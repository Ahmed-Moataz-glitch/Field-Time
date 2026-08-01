import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/features/booking/presentation/screens/my_bookings_screen.dart';
import 'package:field_time/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:field_time/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:field_time/features/home/presentation/screens/home_screen.dart';
import 'package:field_time/features/profile/presentation/screens/profile_screen.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    MyBookingsScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 2) {
              context.read<FavoritesCubit>().loadFavorites(isRefresh: true);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark ? AppColors.textSecondaryDark : AppColors.iconGrey,
          selectedLabelStyle: AppTypography.small(color: AppColors.primary).copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppTypography.small(color: AppColors.iconGrey),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n?.home ?? 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined),
              activeIcon: const Icon(Icons.calendar_today),
              label: l10n?.bookings ?? 'حجوزاتي',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              activeIcon: const Icon(Icons.favorite),
              label: l10n?.favorites ?? 'المفضلة',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n?.profile ?? 'الملف الشخصي',
            ),
          ],
        ),
      ),
    );
  }
}
