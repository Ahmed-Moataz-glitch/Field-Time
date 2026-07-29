import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/widgets/custom_text_field.dart';
import 'package:field_time/core/widgets/loading_skeleton.dart';
import 'package:field_time/features/home/presentation/cubit/home_cubit.dart';
import 'package:field_time/features/home/presentation/cubit/home_state.dart';
import 'package:field_time/features/home/presentation/widgets/category_chip.dart';
import 'package:field_time/features/home/presentation/widgets/field_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = const [
    {'title': 'كل الملاعب', 'icon': Icons.sports_soccer},
    {'title': 'صالات', 'icon': Icons.roofing},
    {'title': 'سباعي', 'icon': Icons.groups},
    {'title': 'خماسي', 'icon': Icons.person},
    {'title': 'فلترة', 'icon': Icons.tune},
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'مرحباً ',
                            style: AppTypography.caption(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            'أحمد 👋',
                            style: AppTypography.title(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            'القاهرة، مصر',
                            style: AppTypography.caption(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 18.sp,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Bell Notification Icon Button
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.greyLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // Search Bar
              CustomTextField(
                controller: _searchController,
                hintText: 'ابحث عن ملعب أو منطقة',
                prefixIcon: const Icon(Icons.search, color: AppColors.iconGrey),
                onChanged: (val) {
                  context.read<HomeCubit>().searchFields(val);
                },
              ),
              SizedBox(height: 20.h),
              // Categories Horizontal List
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  final selectedCategory = (state is HomeLoaded) ? state.selectedCategory : 'كل الملاعب';
                  return SizedBox(
                    height: 44.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => SizedBox(width: 10.w),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat['title'] == selectedCategory;
                        return CategoryChip(
                          title: cat['title'] as String,
                          icon: cat['icon'] as IconData,
                          isSelected: isSelected,
                          onTap: () {
                            context.read<HomeCubit>().selectCategory(cat['title'] as String);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              // Section Header: Fields Near You
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'الملاعب القريبة منك',
                    style: AppTypography.title(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Fields List
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return Column(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: LoadingSkeleton(width: double.infinity, height: 120.h, borderRadius: 20),
                        ),
                      ),
                    );
                  } else if (state is HomeLoaded) {
                    if (state.fields.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Center(
                          child: Text(
                            'لا توجد ملاعب مطابقة للبحث',
                            style: AppTypography.body(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.fields.length,
                      itemBuilder: (context, index) {
                        final field = state.fields[index];
                        return FieldCard(
                          field: field,
                          onTap: () => context.push('/field-details/${field.id}'),
                        );
                      },
                    );
                  } else if (state is HomeError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTypography.body(color: AppColors.error),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
