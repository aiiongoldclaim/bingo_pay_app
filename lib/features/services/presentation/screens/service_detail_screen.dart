import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/service_entity.dart';
import '../cubit/service_detail_cubit.dart';
import '../cubit/service_detail_state.dart';
import '../widgets/service_detail_header.dart';
import '../widgets/offerings_list.dart';
import '../widgets/availability_section.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceEntity? service;
  final String? serviceUuid;

  const ServiceDetailScreen({
    super.key,
    this.service,
    this.serviceUuid,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late String _selectedOfferingUuid;

  @override
  void initState() {
    super.initState();
    _selectedOfferingUuid = '';
  }

  @override
  Widget build(BuildContext context) {
    final serviceUuid = widget.serviceUuid ?? widget.service?.uuid ?? '';

    if (serviceUuid.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: 'Service Details'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 15.w,
                color: Colors.grey,
              ),
              SizedBox(height: 2.h),
              Text(
                'Invalid service ID',
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Service Details'),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<ServiceDetailCubit>()
              ..loadServiceDetail(serviceUuid),
          ),
          BlocProvider(
            create: (_) => getIt<AvailabilityCubit>(),
          ),
        ],
        child: SingleChildScrollView(
          child: BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
            builder: (context, state) {
              if (state.status == ServiceDetailStatus.loading) {
                return SizedBox(
                  height: 50.h,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state.status == ServiceDetailStatus.error) {
                return SizedBox(
                  height: 50.h,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 15.w,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Failed to load service',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        SizedBox(height: 2.h),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<ServiceDetailCubit>()
                                .loadServiceDetail(serviceUuid);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.service == null) {
                return SizedBox(
                  height: 50.h,
                  child: const Center(
                    child: Text('No service data'),
                  ),
                );
              }

              final service = state.service!;

              // Ensure default offering is always selected
              if (_selectedOfferingUuid.isEmpty && service.offerings.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  final offeringUuid = service.offerings.first.uuid;
                  setState(() {
                    _selectedOfferingUuid = offeringUuid;
                  });
                  // Load availability for the default offering
                  if (mounted) {
                    context.read<AvailabilityCubit>().loadAvailability(
                          serviceUuid: serviceUuid,
                          offeringUuid: offeringUuid,
                        );
                  }
                });
              }

              return Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with image and basic info
                    ServiceDetailHeader(service: service),

                    SizedBox(height: 3.h),

                    // Description
                    if (service.description.isNotEmpty) ...[
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.black,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        service.description.isNotEmpty
                            ? service.description
                            : 'No description available',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Offerings
                    if (service.offerings.isNotEmpty) ...[
                      OfferingsList(
                        offerings: service.offerings,
                        selectedUuid: _selectedOfferingUuid,
                        onOfferingSelected: (offering) {
                          setState(() {
                            _selectedOfferingUuid = offering.uuid;
                          });
                          context.read<AvailabilityCubit>().loadAvailability(
                                serviceUuid: serviceUuid,
                                offeringUuid: offering.uuid,
                              );
                        },
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Availability
                    if (_selectedOfferingUuid.isNotEmpty)
                      AvailabilitySection(
                        serviceUuid: serviceUuid,
                        offeringUuid: _selectedOfferingUuid,
                      ),

                    SizedBox(height: 2.h),
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
