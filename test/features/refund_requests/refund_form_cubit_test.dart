import 'package:bingo_pay/features/refund_requests/data/datasource/refund_requests_remote_datasource.dart';
import 'package:bingo_pay/features/refund_requests/data/models/refund_request_model.dart';
import 'package:bingo_pay/features/refund_requests/presentation/cubit/refund_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements RefundRequestsRemoteDataSource {}

// Shaped like GET /refund-requests/orders/:uuid/eligibility (inside `data`).
final _eligibilityJson = <String, dynamic>{
  'order': {'uuid': 'o-1', 'orderNumber': 'ORD-1'},
  'available': true,
  'message': null,
  'lines': [
    {
      'orderItemId': '11',
      'title': 'Watch',
      'quantity': 2,
      'totalAmount': '200.00',
      'vendor': {'uuid': 'v1', 'shopName': 'Shop A'},
      'eligible': true,
      'maxQuantity': 2,
      'reason': null,
      'deadline': '2026-12-01T00:00:00.000Z',
      'reasons': [
        {'code': 'DAMAGED', 'label': 'Damaged', 'requiresEvidence': true, 'customerPaysCharges': false},
        {'code': 'CHANGED_MIND', 'label': 'Changed my mind', 'requiresEvidence': false, 'customerPaysCharges': true},
      ],
      'restockingFeePercent': '10.00',
    },
    {
      'orderItemId': '12',
      'title': 'Ring',
      'quantity': 1,
      'totalAmount': '50.00',
      'vendor': {'uuid': 'v2', 'shopName': 'Shop B'},
      'eligible': true,
      'maxQuantity': 1,
      'reasons': [
        {'code': 'DAMAGED', 'label': 'Damaged', 'requiresEvidence': true, 'customerPaysCharges': false},
      ],
      'restockingFeePercent': '0.00',
    },
    {
      'orderItemId': '13',
      'title': 'Bag',
      'quantity': 1,
      'totalAmount': '30.00',
      'vendor': {'uuid': 'v2', 'shopName': 'Shop B'},
      'eligible': false,
      'maxQuantity': 0,
      'reason': 'The return window closed.',
      'reasons': [],
      'restockingFeePercent': '0.00',
    },
  ],
};

void main() {
  late _MockRemote remote;
  late RefundFormCubit cubit;

  setUp(() async {
    remote = _MockRemote();
    when(() => remote.eligibility('o-1')).thenAnswer(
      (_) async => RefundEligibility.fromJson(_eligibilityJson),
    );
    cubit = RefundFormCubit(remote);
    await cubit.load('o-1');
  });

  tearDown(() => cubit.close());

  RefundLine line(String id) =>
      cubit.state.lines.firstWhere((l) => l.orderItemId == id);

  test('parses eligibility from the API shape', () {
    final e = cubit.state.eligibility!;
    expect(e.orderNumber, 'ORD-1');
    expect(e.available, isTrue);
    expect(line('11').totalAmount, 200);
    expect(line('11').shopName, 'Shop A');
    expect(line('11').reasons.map((r) => r.code), ['DAMAGED', 'CHANGED_MIND']);
    expect(line('13').eligible, isFalse);
    expect(line('13').reason, 'The return window closed.');
  });

  test('reasons are the ones every picked line allows', () {
    cubit.toggle(line('11'));
    expect(cubit.state.reasons.map((r) => r.code), ['DAMAGED', 'CHANGED_MIND']);
    cubit.toggle(line('12'));
    expect(cubit.state.reasons.map((r) => r.code), ['DAMAGED']);
  });

  test('ineligible lines cannot be picked', () {
    cubit.toggle(line('13'));
    expect(cubit.state.selected, isEmpty);
    expect(cubit.state.problem, 'Pick at least one item.');
  });

  test('problem walks items → reason → photos', () {
    cubit.toggle(line('11'));
    expect(cubit.state.problem, 'Pick a reason.');
    cubit.setReason('DAMAGED');
    expect(cubit.state.problem, 'Add at least one photo for this reason.');
    cubit.setReason('CHANGED_MIND');
    expect(cubit.state.problem, isNull);
    // A reason the new selection no longer allows is dropped.
    cubit.toggle(line('12'));
    expect(cubit.state.reason, isNull);
  });

  test('estimate is pro-rata per unit and restocking shows for its reason', () {
    cubit.toggle(line('11')); // both units → 200
    cubit.setQuantity(line('11'), 1);
    expect(cubit.state.estimate, 100);
    cubit.setQuantity(line('11'), 9); // clamped to maxQuantity
    expect(cubit.state.picked['11'], 2);
    cubit.setReason('CHANGED_MIND');
    expect(cubit.state.restockPercent, 10);
    cubit.setReason('DAMAGED');
    expect(cubit.state.restockPercent, 0);
  });

  test('submit sends the picked lines, reason and photos', () async {
    when(
      () => remote.create(
        any(),
        items: any(named: 'items'),
        reasonCode: any(named: 'reasonCode'),
        description: any(named: 'description'),
        evidence: any(named: 'evidence'),
      ),
    ).thenAnswer((_) async => 'Refund request sent.');

    cubit.toggle(line('11'));
    cubit.setQuantity(line('11'), 1);
    cubit.setReason('CHANGED_MIND');
    await cubit.submit('o-1', '  scratched  ');

    verify(
      () => remote.create(
        'o-1',
        items: {'11': 1},
        reasonCode: 'CHANGED_MIND',
        description: 'scratched',
        evidence: const [],
      ),
    ).called(1);
    expect(cubit.state.sentMessage, 'Refund request sent.');
  });

  test('submit does nothing while something is missing', () async {
    await cubit.submit('o-1', '');
    verifyNever(
      () => remote.create(
        any(),
        items: any(named: 'items'),
        reasonCode: any(named: 'reasonCode'),
        description: any(named: 'description'),
        evidence: any(named: 'evidence'),
      ),
    );
  });

  test('request detail parses amounts, events and cancel rule', () {
    final r = RefundRequestModel.fromJson({
      'uuid': 'r-1',
      'reference': 'RR-1',
      'status': 'VENDOR_REVIEW',
      'reasonLabel': 'Damaged',
      'evidence': ['https://x/y.jpg'],
      'itemsAmount': '100.00',
      'chargesAmount': '0.00',
      'refundAmount': '100.00',
      'order': {'uuid': 'o-1', 'orderNumber': 'ORD-1'},
      'vendor': {'uuid': 'v1', 'shopName': 'Shop A'},
      'items': [
        {'orderItemId': '11', 'title': 'Watch', 'sku': 'W1', 'quantity': 1, 'amount': '100.00'},
      ],
      'refund': null,
      'events': [
        {'actorType': 'CUSTOMER', 'action': 'SUBMITTED', 'note': null, 'createdAt': '2026-11-01T10:00:00.000Z'},
      ],
    });
    expect(r.refundAmount, 100);
    expect(r.statusLabel, 'With the seller');
    expect(r.canCancel, isTrue);
    expect(r.events.single.label, 'Request sent');
    expect(r.refundReference, isNull);
    expect(RefundRequestModel.fromJson({'uuid': 'x', 'status': 'REFUNDED'}).canCancel, isFalse);
  });
}
