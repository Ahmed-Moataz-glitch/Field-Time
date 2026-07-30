import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/loading_skeleton.dart';
import 'package:field_time/core/widgets/primary_button.dart';
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
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = const [
    {'title': 'كل الملاعب', 'icon': Icons.sports_soccer_rounded},
    {'title': 'خماسي', 'icon': Icons.person_rounded},
    {'title': 'سباعي', 'icon': Icons.groups_rounded},
    {'title': 'صالات', 'icon': Icons.roofing_rounded},
    {'title': 'العروض', 'icon': Icons.local_offer_rounded},
  ];

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
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

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return _buildLoadingState(isDark);
            }

            if (state is HomeError) {
              return _buildErrorState(context, state.message, isDark);
            }

            if (state is HomeLoaded) {
              final isSearchingOrFiltering = state.searchQuery.isNotEmpty ||
                  state.filterParams.hasActiveFilters ||
                  state.selectedCategory != 'كل الملاعب';

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<HomeCubit>().loadHomeData(isRefresh: true);
                },
                color: AppColors.primary,
                backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header (Greeting + Location Picker + Notifications)
                      HomeHeader(
                        userName: 'أحمد',
                        selectedCity: state.selectedCity,
                        onCityChanged: (city) {
                          context.read<HomeCubit>().selectCity(city);
                        },
                      ),
                      SizedBox(height: 18.h),

                      // 2. Search Bar + Filter Modal Trigger
                      HomeSearchBar(
                        controller: _searchController,
                        onChanged: (val) {
                          context.read<HomeCubit>().searchFields(val);
                        },
                        filterParams: state.filterParams,
                        onFilterApplied: (params) {
                          context.read<HomeCubit>().applyFilter(params);
                        },
                      ),
                      SizedBox(height: 18.h),

                      // 3. Category Horizontal Chips
                      SizedBox(
                        height: 44.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => SizedBox(width: 10.w),
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final title = cat['title'] as String;
                            final isSelected = title == state.selectedCategory;

                            return CategoryChip(
                              title: title,
                              icon: cat['icon'] as IconData,
                              isSelected: isSelected,
                              onTap: () {
                                context.read<HomeCubit>().selectCategory(title);
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // If user is searching or applying filters, show filtered results directly
                      if (isSearchingOrFiltering) ...[
                        _buildSectionHeader(
                          context,
                          title: 'نتائج البحث والتصفية (${state.filteredFields.length})',
                          icon: Icons.filter_alt_rounded,
                        ),
                        SizedBox(height: 14.h),
                        if (state.filteredFields.isEmpty)
                          _buildEmptyState(context, isDark)
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
                                  context.read<HomeCubit>().toggleFavorite(field.id);
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
                            title: l10n?.popularFields ?? 'الملاعب الأكثر شعبية',
                            icon: Icons.local_fire_department_rounded,
                            iconColor: Colors.orangeAccent,
                          ),
                          SizedBox(height: 14.h),
                          SizedBox(
                            height: 220.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.popularFields.length,
                              itemBuilder: (context, index) {
                                final field = state.popularFields[index];
                                final isFav = state.favoriteFieldIds.contains(field.id);
                                return PopularFieldCard(
                                  field: field,
                                  isFavorite: isFav,
                                  onTap: () => context.push('/field-details/${field.id}'),
                                  onFavoriteToggle: () {
                                    context.read<HomeCubit>().toggleFavorite(field.id);
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
                          title: l10n?.nearbyFields ?? 'ملاعب قريبة منك',
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
                                context.read<HomeCubit>().toggleFavorite(field.id);
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20.h),

                        // 7. Recommended Fields Section
                        if (state.recommendedFields.isNotEmpty) ...[
                          _buildSectionHeader(
                            context,
                            title: l10n?.recommendedFields ?? 'ملاعب مقترحة لك',
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
                                  context.read<HomeCubit>().toggleFavorite(field.id);
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
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color iconColor = AppColors.primary,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

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
        Text(
          l10n?.seeAll ?? 'عرض الكل',
          style: AppTypography.caption(color: AppColors.primary).copyWith(
            fontWeight: FontWeight.w600,
          ),
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

  Widget _buildErrorState(BuildContext context, String message, bool isDark) {
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
              l10n?.errorOccurred ?? 'حدث خطأ غير متوقع',
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
                title: l10n?.retry ?? 'إعادة المحاولة',
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

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56.sp,
            color: isDark ? AppColors.textSecondaryDark : AppColors.iconGrey,
          ),
          SizedBox(height: 12.h),
          Text(
            l10n?.noData ?? 'لا توجد ملاعب مطابقة للبحث',
            style: AppTypography.body(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
