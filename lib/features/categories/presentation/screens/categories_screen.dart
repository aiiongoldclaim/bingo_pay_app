import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import '../widgets/brand_grid.dart';
import '../widgets/categories_grid.dart';
import '../widgets/curated_collection_list.dart';
import '../widgets/section_header.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesCubit()..loadData(),
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            child: Scaffold(
              backgroundColor: ThemeColors.background,
              appBar: CustomAppBar(
                title: 'Categories',
                actionIcon1: Icons.search_rounded,
                onAction1: () {
                  context.push(AppRoutes.search);
                },
              ),
              body: SafeArea(
                top: false,
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.categories.isNotEmpty) ...[
                              const SectionTitle(title: 'Categories'),
                              SizedBox(height: 2.h),
                              CategoriesGrid(categories: state.categories),
                              SizedBox(height: 2.h),
                            ],

                            const SectionTitle(title: 'Top brands'),
                            SizedBox(height: 2.h),
                            BrandsGrid(brands: state.brands),

                            SizedBox(height: 2.h),

                            const SectionTitle(title: 'Curated collections'),
                            SizedBox(height: 2.h),
                            CuratedCollectionsList(
                                collections: state.collections),

                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
