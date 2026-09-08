import 'package:bingo_pay/features/bookings/domain/entities/booking_details_entity.dart';
import 'package:bingo_pay/features/bookings/domain/entities/bookings_entity.dart'
    hide
        BookingServiceEntity,
        BookingOfferingEntity,
        BookingVendorEntity,
        BookingOrderEntity;
import 'package:bingo_pay/features/bookings/domain/entities/cancel_booking_entity.dart';
import 'package:bingo_pay/features/bookings/domain/repositories/booking_repository.dart';
import 'package:bingo_pay/features/bookings/presentation/cubit/booking_cubit.dart';
import 'package:bingo_pay/features/bookings/presentation/screens/booking_details_screen.dart';
import 'package:bingo_pay/features/services/data/datasources/services_remote_datasource.dart';
import 'package:bingo_pay/features/services/data/models/availability_model.dart';
import 'package:bingo_pay/features/services/data/models/service_detail_model.dart';
import 'package:bingo_pay/features/services/data/models/services_response_model.dart';
import 'package:bingo_pay/features/services/domain/usecases/get_service_detail_usecase.dart';
import 'package:bingo_pay/features/services/presentation/cubit/services_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeServiceRemoteDataSource implements ServiceRemoteDataSource {
  @override
  Future<ServicesResponseModel> getServices({int limit = 8, int page = 1}) =>
      throw UnimplementedError();

  @override
  Future<ServiceDetailModel> getServiceDetail(String serviceUuid) =>
      throw UnimplementedError();

  @override
  Future<AvailabilityResponseModel> getServiceAvailability({
    required String serviceUuid,
    required String offeringUuid,
    int participants = 1,
  }) => throw UnimplementedError();
}

BookingDetailsEntity _fakeBooking() {
  final serviceType = BookingServiceTypeEntity(
    id: 'st1',
    uuid: 'st1',
    code: 'code',
    name: 'Salon',
    description: '',
    schedulingModel: 'slot',
    deliveryMode: 'in_person',
    capacityModel: 'single',
    requiresQuotation: false,
    requiresStaff: false,
    requiresResource: false,
    allowsRescheduling: true,
    isActive: true,
    isSystem: false,
    sortOrder: 0,
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
  );

  final service = BookingServiceEntity(
    id: 's1',
    uuid: 's1',
    vendorId: 'v1',
    categoryId: 'c1',
    serviceTypeId: 'st1',
    title: 'Haircut & Styling',
    slug: 'haircut-styling',
    shortDescription: '',
    description: '',
    status: 'active',
    durationMinutes: 60,
    bufferMinutes: 0,
    leadTimeMinutes: 0,
    bookingWindowDays: 30,
    allowSameDayBooking: true,
    allowPayAfterService: false,
    latitude: '0',
    longitude: '0',
    locationLabel: 'Downtown',
    isPublished: true,
    isFeatured: false,
    averageRating: 4.5,
    totalReviews: 10,
    listingLevel: 'standard',
    visibility: 'public',
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
    serviceType: serviceType,
  );

  final offering = BookingOfferingEntity(
    id: 'o1',
    uuid: 'o1',
    serviceId: 's1',
    code: 'default',
    title: 'Standard',
    offeringName: 'Standard Cut',
    combinationKey: 'default',
    pricingModelId: 'p1',
    basePrice: '500',
    currency: 'INR',
    durationMinutes: 60,
    minParticipants: 1,
    maxParticipants: 1,
    isDefault: true,
    isActive: true,
    sortOrder: 0,
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
  );

  final vendor = BookingVendorEntity(uuid: 'v1', shopName: 'Style Studio');

  final address = BookingAddressEntity(
    id: 'a1',
    userId: 'u1',
    fullName: 'Test User',
    phone: '9999999999',
    addressLine1: '123 Main St',
    city: 'Mumbai',
    state: 'MH',
    country: 'IN',
    postalCode: '400001',
    isDefault: true,
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
  );

  final order = BookingOrderEntity(uuid: 'ord1', orderNumber: 'ORD-1001');

  return BookingDetailsEntity(
    id: 'b1',
    uuid: 'b1',
    bookingNumber: 'BK-1001',
    orderItemId: 'oi1',
    vendorOrderId: 'vo1',
    orderId: 'ord1',
    userId: 'u1',
    vendorId: 'v1',
    serviceId: 's1',
    offeringId: 'o1',
    slotId: 'slot1',
    status: 'CONFIRMED',
    scheduledStartAt: '2026-02-01T10:00:00.000Z',
    scheduledEndAt: '2026-02-01T11:00:00.000Z',
    participants: 1,
    addressId: 'a1',
    rescheduleCount: 0,
    paymentMode: 'PREPAID',
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
    service: service,
    offering: offering,
    vendor: vendor,
    address: address,
    order: order,
    timeline: const [],
    assignments: const [],
  );
}

class _FakeBookingRepository implements BookingRepository {
  Future<BookingDetailsEntity> Function()? nextDetailsCall;

  @override
  Future<List<BookingEntity>> getBookings() async => [];

  @override
  Future<BookingDetailsEntity> getBookingDetails(String bookingUuid) {
    final call = nextDetailsCall;
    if (call != null) return call();
    return Future.value(_fakeBooking());
  }

  @override
  Future<CancelBookingEntity> cancelBooking({
    required String bookingUuid,
    required String reason,
  }) => throw UnimplementedError();

  @override
  Future<BookingDetailsEntity> rescheduleBooking({
    required String bookingUuid,
    required String slotUuid,
  }) => throw UnimplementedError();
}

void main() {
  testWidgets(
    'pulling to refresh on Booking Details keeps the loaded content on '
    'screen instead of flashing the full-page skeleton',
    (tester) async {
      final repo = _FakeBookingRepository();
      final cubit = BookingCubit(repo);
      addTearDown(cubit.close);

      final availabilityCubit = AvailabilityCubit(
        GetServiceAvailabilityUseCase(_FakeServiceRemoteDataSource()),
      );
      addTearDown(availabilityCubit.close);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<BookingCubit>.value(value: cubit),
              BlocProvider<AvailabilityCubit>.value(value: availabilityCubit),
            ],
            child: const BookingDetailsScreen(bookingUuid: 'b1'),
          ),
        ),
      );

      // Initial load completes.
      await tester.pumpAndSettle();

      expect(find.text('Booking Details'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Simulate what RefreshIndicator.onRefresh does: re-trigger the fetch,
      // but hold the new response open so we can inspect the UI mid-refresh —
      // exactly the moment BookingDetailLoading is emitted.
      repo.nextDetailsCall = () => Future.delayed(
        const Duration(milliseconds: 500),
        _fakeBooking,
      );

      final refreshFuture = cubit.fetchBookingDetails('b1');
      await tester.pump(); // rebuild for the freshly emitted BookingDetailLoading

      expect(
        find.text('Booking Details'),
        findsOneWidget,
        reason:
            'the header/content must stay mounted during a refresh — if it '
            'disappears, the full-page loading skeleton took over instead '
            'of the compact RefreshIndicator spinner',
      );
      expect(
        find.byType(RefreshIndicator),
        findsOneWidget,
        reason: 'the RefreshIndicator itself must not be torn down mid-refresh',
      );

      await tester.pump(const Duration(milliseconds: 500));
      await refreshFuture;
      await tester.pumpAndSettle();

      expect(find.text('Booking Details'), findsOneWidget);
    },
  );
}
