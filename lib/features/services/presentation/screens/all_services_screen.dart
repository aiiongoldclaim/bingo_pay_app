import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../cubit/services_cubit.dart';
import '../cubit/services_state.dart';
import '../widgets/all_services_shimmer.dart';
import '../widgets/service_card.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  late ScrollController _scrollController;
  late ServicesCubit _servicesCubit;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _servicesCubit = getIt<ServicesCubit>();
    _servicesCubit.loadAllServices();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _servicesCubit.loadMoreServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider<ServicesCubit>.value(
      value: _servicesCubit,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: const CustomAppBar(title: 'All Services'),
        body: BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            if (state.status == ServicesStatus.loading) {
              return const AllServicesShimmer();
            }

            if (state.status == ServicesStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 15.w,
                      color: colors.textMuted,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Failed to load services',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      state.errorMessage ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                   AppButton(
                      onPressed: () {
                        _servicesCubit.loadAllServices();
                      },
                       label: 'Retry',

                    ),
                  ],
                ),
              );
            }

            if (state.services.isEmpty) {
              return Center(
                child: Text(
                  'No services available',
                  style: TextStyle(fontSize: 16.sp, color: colors.textPrimary),
                ),
              );
            }

            return GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 2.h,
                childAspectRatio: 0.78,
              ),
              itemCount: state.services.length + (state.hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator at the end
                if (index >= state.services.length) {
                  return Center(
                    child: CircularProgressIndicator(color: colors.brand),
                  );
                }

                final service = state.services[index];

                return ServiceCard(
                  service: service,
                  onTap: () {
                    context.push(
                      AppRoutes.serviceDetailPath(service.uuid),
                      extra: service,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
