import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/localization/locale_cubit.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:field_time/features/home/presentation/widgets/field_card.dart';
import 'package:field_time/l10n/generated/app_localizations.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<FavoritesCubit>().loadFavorites(isRefresh: true);
    });
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l10n?.favorites ?? (isArabic ? 'المفضلة' : 'Favorites'),
          style: AppTypography.heading3(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: BlocConsumer<FavoritesCubit, FavoritesState>(
          listener: (context, state) {
            if (state is FavoritesLoaded && state.lastRemovedField != null) {
              final removedField = state.lastRemovedField!;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'تم إزالة "${removedField.name}" من المفضلة'
                        : 'Removed "${removedField.name}" from favorites',
                    style: AppTypography.body(color: Colors.white),
                  ),
                  backgroundColor: isDark ? AppColors.cardDark : AppColors.textPrimaryLight,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: isArabic ? 'تراجع' : 'Undo',
                    textColor: AppColors.primary,
                    onPressed: () {
                      context.read<FavoritesCubit>().undoRemoveFavorite();
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is FavoritesError) {
              return _buildErrorState(context, state.message, isDark, isArabic);
            }

            if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return _buildEmptyState(context, isDark, isArabic);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<FavoritesCubit>().loadFavorites(isRefresh: true);
                },
                color: AppColors.primary,
                backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header info & count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic ? 'الملاعب المفضلة لديك' : 'Your Favorite Fields',
                            style: AppTypography.title(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              isArabic ? '${state.favorites.length} ملاعب' : '${state.favorites.length} fields',
                              style: AppTypography.caption(color: AppColors.primary).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Search filter bar within favorites if favorites >= 2
                      if (state.favorites.length >= 2) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.greyLight,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              context.read<FavoritesCubit>().searchFavorites(val);
                            },
                            style: AppTypography.body(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            decoration: InputDecoration(
                              hintText: isArabic ? 'ابحث في ملاعبك المفضلة...' : 'Search in favorite fields...',
                              hintStyle: AppTypography.body(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.iconGrey,
                                size: 20.sp,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, size: 18.sp, color: AppColors.iconGrey),
                                      onPressed: () {
                                        _searchController.clear();
                                        context.read<FavoritesCubit>().searchFavorites('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],

                      // Search empty state or list
                      if (state.filteredFavorites.isEmpty && state.searchQuery.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48.sp,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.iconGrey,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                isArabic
                                    ? 'لا توجد ملاعب مفضلة تطابق "${state.searchQuery}"'
                                    : 'No favorite fields match "${state.searchQuery}"',
                                style: AppTypography.body(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.filteredFavorites.length,
                          itemBuilder: (context, index) {
                            final field = state.filteredFavorites[index];
                            final isFav = state.favoriteIds.contains(field.id);
                            return FieldCard(
                              field: field,
                              isFavorite: isFav,
                              onTap: () => context.push('/field-details/${field.id}'),
                              onFavoriteToggle: () {
                                context.read<FavoritesCubit>().removeFavorite(field);
                              },
                            );
                          },
                        ),
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

  Widget _buildEmptyState(BuildContext context, bool isDark, bool isArabic) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<FavoritesCubit>().loadFavorites(isRefresh: true);
      },
      color: AppColors.primary,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 60.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 60.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    isArabic ? 'لا توجد ملاعب مفضلة حالياً' : 'No Favorite Fields Yet',
                    style: AppTypography.heading3(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    isArabic
                        ? 'أضف ملاعبك المفضلة بالنقر على رمز القلب في بطاقات الملاعب لتتمكن من الوصول إليها وحجزها بسرعة في أي وقت.'
                        : 'Add fields to your favorites by tapping the heart icon on field cards to quickly access and book them anytime.',
                    style: AppTypography.body(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 28.h),
                  SizedBox(
                    width: 200.w,
                    child: PrimaryButton(
                      title: isArabic ? 'استكشف الملاعب' : 'Explore Fields',
                      onPressed: () {
                        context.go('/main');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDark, bool isArabic) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              isArabic ? 'حدث خطأ أثناء تحميل المفضلة' : 'An error occurred loading favorites',
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
                title: isArabic ? 'إعادة المحاولة' : 'Retry',
                onPressed: () {
                  context.read<FavoritesCubit>().loadFavorites();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
