import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/localization/locale_cubit.dart';
import 'package:field_time/core/widgets/loading_skeleton.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:field_time/features/home/presentation/cubit/home_cubit.dart';
import 'package:field_time/features/home/presentation/cubit/home_state.dart';
import 'package:field_time/features/home/presentation/widgets/category_chip.dart';
import 'package:field_time/features/home/presentation/widgets/field_card.dart';
import 'package:field_time/features/home/presentation/widgets/home_header.dart';
import 'package:field_time/features/home/presentation/widgets/home_search_bar.dart';
import 'package:field_time/features/home/presentation/widgets/offers_slider.dart';
import 'package:field_time/features/home/presentation/widgets/popular_field_card.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _getCategories(bool isArabic) {
    return [
      {'title': isArabic ? 'كل الملاعب' : 'All Fields', 'rawKey': 'كل الملاعب', 'icon': Icons.sports_soccer_rounded},
      {'title': isArabic ? 'خماسي' : '5v5', 'rawKey': 'خماسي', 'icon': Icons.groups_rounded},
      {'title': isArabic ? 'سباعي' : '7v7', 'rawKey': 'سباعي', 'icon': Icons.stadium_rounded},
      {'title': '11v11', 'rawKey': '11v11', 'icon': Icons.flag_rounded},
      {'title': isArabic ? 'صالات' : 'Indoor', 'rawKey': 'صالات', 'icon': Icons.domain_rounded},
      {'title': isArabic ? 'العروض' : 'Offers', 'rawKey': 'العروض', 'icon': Icons.local_offer_rounded},
    ];
  }

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
  }

  void _toggleFavorite(BuildContext context, String fieldId) async {
    await context.read<HomeCubit>().toggleFavorite(fieldId);
    if (context.mounted) {
      try {
        context.read<FavoritesCubit>().loadFavorites(isRefresh: true);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isArabic = context.watch<LocaleCubit>().state.isArabic;
    final categories = _getCategories(isArabic);

    return Scaffold(
      body: SafeArea(
        child: BlocListener<FavoritesCubit, FavoritesState>(
          listener: (context, favState) {
            if (favState is FavoritesLoaded) {
              context.read<HomeCubit>().syncFavorites(favState.favoriteIds);
            }
          },
          child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return _buildLoadingState(isDark);
            }

            if (state is HomeError) {
              return _buildErrorState(context, state.message, isDark, isArabic);
            }

            if (state is HomeLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<HomeCubit>().loadHomeData(isRefresh: true);
                  if (context.mounted) {
                    try {
                      await context.read<FavoritesCubit>().loadFavorites(isRefresh: true);
                    } catch (_) {}
                  }
                },
                color: AppColors.primary,
                backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header with greeting, location & notification icon
                      HomeHeader(
                        userName: isArabic ? 'أحمد' : 'Ahmed',
                        selectedCity: state.selectedCity,
                        onCityChanged: (city) {
                          context.read<HomeCubit>().selectCity(city);
                        },
                      ),
                      SizedBox(height: 20.h),

                      // 2. Search Bar
                      HomeSearchBar(
                        controller: _searchController,
                        onChanged: (query) {
                          context.read<HomeCubit>().searchFields(query);
                        },
                        filterParams: state.filterParams,
                        onFilterApplied: (params) {
                          context.read<HomeCubit>().applyFilter(params);
                        },
                      ),
                      SizedBox(height: 20.h),

                      // 3. Category Filter Chips
                      SizedBox(
                        height: 40.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => SizedBox(width: 10.w),
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final displayTitle = cat['title'] as String;
                            final rawKey = cat['rawKey'] as String;
                            final icon = cat['icon'] as IconData;
                            final isSelected = state.selectedCategory == rawKey || state.selectedCategory == displayTitle;

                            return CategoryChip(
                              title: displayTitle,
                              icon: icon,
                              isSelected: isSelected,
                              onTap: () {
                                context.read<HomeCubit>().selectCategory(rawKey);
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Show Category/Search Filtered List if active filter
                      if (state.selectedCategory != 'كل الملاعب' ||
                          state.searchQuery.isNotEmpty ||
                          state.filterParams.hasActiveFilters) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isArabic
                                  ? 'نتائج البحث (${state.filteredFields.length})'
                                  : 'Search Results (${state.filteredFields.length})',
                              style: AppTypography.title(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                context.read<HomeCubit>().selectCategory('كل الملاعب');
                              },
                              child: Text(
                                isArabic ? 'مسح الكل' : 'Clear All',
                                style: AppTypography.caption(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        if (state.filteredFields.isEmpty)
                          _buildEmptyState(context, isDark, isArabic)
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.filteredFields.length,
                            itemBuilder: (context, index) {
                              final field = state.filteredFields[index];
                              final isFav = state.favoriteFieldIds.contains(field.id);
                              return FieldCard(
                                field: field,
                                isFavorite: isFav,
                                onTap: () => context.push('/field-details/${field.id}'),
                                onFavoriteToggle: () {
                                  _toggleFavorite(context, field.id);
                                },
                              );
                            },
                          ),
                      ] else ...[
                        // 4. Offers Slider Banner
                        if (state.offers.isNotEmpty) ...[
                          OffersSlider(offers: state.offers),
                          SizedBox(height: 24.h),
                        ],

                        // 5. Popular Fields Horizontal Carousel
                        if (state.popularFields.isNotEmpty) ...[
                          _buildSectionHeader(
                            context,
                            title: l10n?.popularFields ?? (isArabic ? 'الملاعب الأكثر شعبية' : 'Popular Fields'),
                            icon: Icons.local_fire_department_rounded,
                            iconColor: Colors.orangeAccent,
                          ),
                          SizedBox(height: 14.h),
                          SizedBox(
                            height: 230.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.popularFields.length,
                              itemBuilder: (context, index) {
                                final field = state.popularFields[index];
                                final isFav = state.favoriteFieldIds.contains(field.id);
                                return PopularFieldCard(
                                  field: field,
                                  isFavorite: isFav,
                                  onTap: () async {
                                    final cubit = context.read<HomeCubit>();
                                    await context.push('/field-details/${field.id}');
                                    cubit.loadHomeData();
                                  },
                                  onFavoriteToggle: () {
                                    _toggleFavorite(context, field.id);
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],

                        // 6. Nearby Fields Section
                        _buildSectionHeader(
                          context,
                          title: l10n?.nearbyFields ?? (isArabic ? 'ملاعب قريبة منك' : 'Nearby Fields'),
                          icon: Icons.near_me_rounded,
                        ),
                        SizedBox(height: 14.h),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.nearbyFields.length,
                          itemBuilder: (context, index) {
                            final field = state.nearbyFields[index];
                            final isFav = state.favoriteFieldIds.contains(field.id);
                            return FieldCard(
                              field: field,
                              isFavorite: isFav,
                              onTap: () => context.push('/field-details/${field.id}'),
                              onFavoriteToggle: () {
                                _toggleFavorite(context, field.id);
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20.h),

                        // 7. Recommended Fields Section
                        if (state.recommendedFields.isNotEmpty) ...[
                          _buildSectionHeader(
                            context,
                            title: l10n?.recommendedFields ?? (isArabic ? 'ملاعب مقترحة لك' : 'Recommended Fields'),
                            icon: Icons.thumb_up_alt_rounded,
                          ),
                          SizedBox(height: 14.h),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.recommendedFields.length,
                            itemBuilder: (context, index) {
                              final field = state.recommendedFields[index];
                              final isFav = state.favoriteFieldIds.contains(field.id);
                              return FieldCard(
                                field: field,
                                isFavorite: isFav,
                                onTap: () => context.push('/field-details/${field.id}'),
                                onFavoriteToggle: () {
                                  _toggleFavorite(context, field.id);
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color iconColor = AppColors.primary,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              title,
              style: AppTypography.title(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LoadingSkeleton(width: 140.w, height: 40.h, borderRadius: 12),
              LoadingSkeleton(width: 44.w, height: 44.h, borderRadius: 22),
            ],
          ),
          SizedBox(height: 20.h),
          LoadingSkeleton(width: double.infinity, height: 50.h, borderRadius: 16),
          SizedBox(height: 20.h),
          LoadingSkeleton(width: double.infinity, height: 155.h, borderRadius: 22),
          SizedBox(height: 24.h),
          Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: LoadingSkeleton(
                  width: double.infinity,
                  height: 120.h,
                  borderRadius: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDark, bool isArabic) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              l10n?.errorOccurred ?? (isArabic ? 'حدث خطأ غير متوقع' : 'An error occurred'),
              style: AppTypography.title(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTypography.body(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 160.w,
              child: PrimaryButton(
                title: l10n?.retry ?? (isArabic ? 'إعادة المحاولة' : 'Retry'),
                onPressed: () {
                  context.read<HomeCubit>().loadHomeData();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, bool isArabic) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(
            Icons.sports_soccer_outlined,
            size: 64.sp,
            color: isDark ? AppColors.textSecondaryDark : AppColors.iconGrey,
          ),
          SizedBox(height: 16.h),
          Text(
            isArabic ? 'لا توجد ملاعب مطابقة لمحددات البحث' : 'No fields match your search filters',
            style: AppTypography.title(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            isArabic ? 'جرب تغيير كلمة البحث أو فلاتر التصفية.' : 'Try changing your search terms or filters.',
            style: AppTypography.body(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
