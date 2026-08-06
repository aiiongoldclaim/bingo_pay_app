import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../cubit/services_cubit.dart';
import '../cubit/services_state.dart';
import 'service_card.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        if (state.status == ServicesStatus.loading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.status == ServicesStatus.error) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Text(
              'Failed to load services',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red,
              ),
            ),
          );
        }

        if (state.services.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Book Services',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 18.sp,
                      color: ThemeColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      context.push(AppRoutes.services);
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: ThemeColors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            SizedBox(
              height: 28.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: state.services.length,
                itemBuilder: (_, index) {
                  final service = state.services[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 2.5.w),
                    child: ServiceCard(
                      service: service,
                      onTap: () {
                        context.push(
                          '/service-detail/${service.uuid}',
                          extra: service,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
