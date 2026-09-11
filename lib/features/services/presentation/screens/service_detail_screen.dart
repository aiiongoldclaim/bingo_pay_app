import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/service_entity.dart';
import '../cubit/services_cubit.dart';
import '../cubit/services_state.dart';
import '../widgets/service_detail_header.dart';
import '../widgets/service_detail_shimmer.dart';
import '../widgets/offerings_list.dart';
import '../widgets/availability_section.dart';
import 'service_checkout_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceEntity? service;
  final String? serviceUuid;

  const ServiceDetailScreen({super.key, this.service, this.serviceUuid});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late String _selectedOfferingUuid;

  String? _selectedSlotUuid;
  String _bookingDate = '';
  String _bookingTime = '';

  @override
  void initState() {
    super.initState();
    _selectedOfferingUuid = '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final serviceUuid = widget.serviceUuid ?? widget.service?.uuid ?? '';

    if (serviceUuid.isEmpty) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: const CustomAppBar(title: 'Service Details'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 15.w, color: colors.textMuted),
              SizedBox(height: 2.h),
              Text(
                'Invalid service ID',
                style: TextStyle(fontSize: 16.sp, color: colors.textPrimary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const CustomAppBar(title: 'Service Details'),
      body: Column(
        children: [
          Expanded(
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) =>
                      getIt<ServiceDetailCubit>()
                        ..loadServiceDetail(serviceUuid),
                ),
                BlocProvider(create: (_) => getIt<AvailabilityCubit>()),
              ],
              child: SingleChildScrollView(
                child: BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
                  builder: (context, state) {
                    if (state.status == ServiceDetailStatus.loading) {
                      return const ServiceDetailShimmer();
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
                                color: colors.textMuted,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Failed to load service',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: colors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<ServiceDetailCubit>()
                                      .loadServiceDetail(serviceUuid);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.brand,
                                  foregroundColor: colors.onBrand,
                                ),
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
                        child: Center(
                          child: Text(
                            'No service data',
                            style: TextStyle(color: colors.textPrimary),
                          ),
                        ),
                      );
                    }

                    final service = state.service!;

                    // Ensure default offering is always selected
                    if (_selectedOfferingUuid.isEmpty &&
                        service.offerings.isNotEmpty) {
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
                                color: colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              service.description.isNotEmpty
                                  ? service.description
                                  : 'No description available',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: colors.textSecondary,
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
                                  _selectedSlotUuid = null;
                                  _bookingDate = '';
                                  _bookingTime = '';
                                });
                                context
                                    .read<AvailabilityCubit>()
                                    .loadAvailability(
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
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _selectedSlotUuid = selection?.slotUuid;
                                  _bookingDate = selection?.bookingDate ?? '';
                                  _bookingTime = selection?.bookingTime ?? '';
                                });
                              },
                            ),

                          SizedBox(height: 2.h),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (_selectedOfferingUuid.isNotEmpty)
            _buildBookNowBar(context, serviceUuid),
        ],
      ),
    );
  }

  Widget _buildBookNowBar(BuildContext context, String serviceUuid) {
    final colors = context.colors;
    final hasSlot = _selectedSlotUuid != null;

    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 0.6.h),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: hasSlot ? 'Book Now' : 'Select a Time Slot',
          onPressed: hasSlot
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceCheckoutScreen(
                        serviceUuid: serviceUuid,
                        offeringUuid: _selectedOfferingUuid,
                        bookingDate: _bookingDate,
                        bookingTime: _bookingTime,
                        slotUuid: _selectedSlotUuid,
                        participants: 1,
                      ),
                    ),
                  );
                }
              : null,
          prefixIcon: hasSlot ? Icons.check_circle_rounded : null,
          height: 6.6.h,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
