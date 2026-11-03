import 'package:bingo_pay/features/reviews/data/datasource/reviews_remote_datasource.dart';
import 'package:bingo_pay/features/reviews/data/models/review_models.dart';
import 'package:bingo_pay/features/reviews/presentation/cubit/review_form_cubit.dart';
import 'package:bingo_pay/features/reviews/presentation/cubit/reviews_cubits.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements ReviewsRemoteDataSource {}

// Shaped like GET /reviews/orders/:uuid/eligibility (inside `data`).
Map<String, dynamic> _eligibility({
  bool canWrite = true,
  Map<String, dynamic>? agent,
  List<Map<String, dynamic>>? items,
}) => {
  'order': {'uuid': 'o-1', 'orderNumber': 'ORD-1'},
  'canWrite': canWrite,
  'message': canWrite ? null : 'Seller accounts cannot write reviews.',
  'deliveries': [
    {
      'vendorOrderUuid': 'vo-1',
      'vendor': {'uuid': 'v1', 'shopName': 'Shop A'},
      'status': 'DELIVERED',
      'agent': agent,
      'agentReview': {
        'eligible': canWrite,
        'reason': null,
        'reviewableUntil': '2027-01-01T00:00:00.000Z',
        'review': null,
      },
      'items':
          items ??
          [
            {
              'orderItemId': '11',
              'productUuid': 'p-1',
              'title': 'Watch',
              'eligible': canWrite,
              'reason': null,
              'reviewableUntil': '2027-01-01T00:00:00.000Z',
              'review': null,
            },
          ],
    },
  ],
};

const _productReview = Review(
  kind: ReviewKind.product,
  uuid: 'r-1',
  rating: 4,
  title: 'Nice',
  comment: 'Good watch',
  images: ['https://cdn/x.jpg'],
  status: 'APPROVED',
  canEdit: true,
  subject: 'Watch',
);

void main() {
  setUpAll(() => registerFallbackValue(ReviewKind.product));

  group('models', () {
    test('eligibility parses lines and the delivery agent', () {
      final e = ReviewEligibility.fromJson(
        _eligibility(agent: {'uuid': 'a-1', 'name': 'Priya S.'}),
      );
      final d = e.deliveries.single;
      expect(e.canWrite, isTrue);
      expect(d.shopName, 'Shop A');
      expect(d.agentName, 'Priya S.');
      expect(d.items.single.orderItemId, '11');
      expect(d.items.single.slot.eligible, isTrue);
      expect(e.showsAgent(d), isTrue);
      expect(e.hasAnything, isTrue);
    });

    test('no agent named: no agent row; nothing to show: hidden', () {
      final e = ReviewEligibility.fromJson(
        _eligibility(
          items: [
            {
              'orderItemId': '11',
              'title': 'Gift card',
              'eligible': false,
              'reason': 'NOT_A_PRODUCT',
              'review': null,
            },
          ],
        ),
      );
      expect(e.showsAgent(e.deliveries.single), isFalse);
      expect(e.hasAnything, isFalse);
    });

    test('a written review and a known reason both show', () {
      final e = ReviewEligibility.fromJson(
        _eligibility(
          items: [
            {
              'orderItemId': '11',
              'title': 'Watch',
              'eligible': false,
              'reason': 'ALREADY_REVIEWED',
              'review': {'uuid': 'r-1', 'rating': 5, 'status': 'PENDING'},
            },
            {
              'orderItemId': '12',
              'title': 'Ring',
              'eligible': false,
              'reason': 'WINDOW_CLOSED',
              'review': null,
            },
          ],
        ),
      );
      final items = e.deliveries.single.items;
      expect(items[0].slot.review!.rating, 5);
      expect(items[1].slot.reasonText, 'Review period has ended');
      expect(e.hasAnything, isTrue);
    });

    test('review and summary parse the API shapes', () {
      final agent = Review.fromJson({
        'uuid': 'r-2',
        'rating': 5,
        'comment': 'On time',
        'status': 'APPROVED',
        'agent': {'uuid': 'a-1', 'name': 'Priya S.'},
        'order': {'uuid': 'o-1', 'orderNumber': 'ORD-1'},
        'canEdit': true,
      }, ReviewKind.agent);
      expect(agent.subject, 'Delivery by Priya S. · order ORD-1');

      final product = Review.fromJson({
        'uuid': 'r-1',
        'rating': 4,
        'images': ['https://cdn/x.jpg', 'javascript:alert(1)'],
        'reviewer': 'Asha K.',
        'verifiedPurchase': true,
        'product': {'uuid': 'p-1', 'title': 'Watch'},
      }, ReviewKind.product);
      expect(product.subject, 'Watch');
      expect(product.images, ['https://cdn/x.jpg']);

      final summary = ReviewSummary.fromJson({
        'averageRating': 4.5,
        'totalReviews': 2,
        'distribution': {'1': 0, '2': 0, '3': 0, '4': 1, '5': 1},
      });
      expect(summary.averageRating, 4.5);
      expect(summary.distribution[5], 1);
      expect(
        ReviewSummary.fromJson({'averageRating': null}).averageRating,
        isNull,
      );
    });
  });

  group('ReviewFormCubit', () {
    late _MockRemote remote;
    late ReviewFormCubit cubit;

    setUp(() {
      remote = _MockRemote();
      cubit = ReviewFormCubit(remote);
    });
    tearDown(() => cubit.close());

    test('needs a rating before sending', () async {
      await cubit.start(
        const ReviewFormArgs(
          kind: ReviewKind.product,
          subject: 'Watch',
          orderItemId: '11',
        ),
      );
      await cubit.submit(comment: 'x');
      expect(cubit.state.error, 'Pick a rating from 1 to 5 stars.');
      verifyNever(
        () => remote.createProductReview(
          orderItemId: any(named: 'orderItemId'),
          rating: any(named: 'rating'),
        ),
      );
    });

    test('creates a product review with trimmed text', () async {
      when(
        () => remote.createProductReview(
          orderItemId: any(named: 'orderItemId'),
          rating: any(named: 'rating'),
          title: any(named: 'title'),
          comment: any(named: 'comment'),
          images: any(named: 'images'),
        ),
      ).thenAnswer((_) async => _productReview);

      await cubit.start(
        const ReviewFormArgs(
          kind: ReviewKind.product,
          subject: 'Watch',
          orderItemId: '11',
        ),
      );
      cubit.setRating(4);
      await cubit.submit(title: '  ', comment: ' Good watch ');

      verify(
        () => remote.createProductReview(
          orderItemId: '11',
          rating: 4,
          title: null,
          comment: 'Good watch',
          images: const [],
        ),
      ).called(1);
      expect(cubit.state.doneMessage, 'Thanks for your review');
    });

    test('rates a delivery', () async {
      when(
        () => remote.createAgentReview(
          agentUuid: any(named: 'agentUuid'),
          vendorOrderUuid: any(named: 'vendorOrderUuid'),
          rating: any(named: 'rating'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => _productReview);

      await cubit.start(
        const ReviewFormArgs(
          kind: ReviewKind.agent,
          subject: 'Delivery',
          agentUuid: 'a-1',
          vendorOrderUuid: 'vo-1',
        ),
      );
      cubit.setRating(5);
      await cubit.submit(comment: '');

      verify(
        () => remote.createAgentReview(
          agentUuid: 'a-1',
          vendorOrderUuid: 'vo-1',
          rating: 5,
          comment: null,
        ),
      ).called(1);
    });

    test('editing by uuid finds the review and updates it', () async {
      when(
        () => remote.mine(ReviewKind.product),
      ).thenAnswer((_) async => [_productReview]);
      when(
        () => remote.update(
          any(),
          any(),
          rating: any(named: 'rating'),
          title: any(named: 'title'),
          comment: any(named: 'comment'),
          images: any(named: 'images'),
        ),
      ).thenAnswer((_) async => _productReview);

      await cubit.start(
        const ReviewFormArgs(
          kind: ReviewKind.product,
          subject: 'Watch',
          reviewUuid: 'r-1',
        ),
      );
      expect(cubit.state.existing?.uuid, 'r-1');
      expect(cubit.state.rating, 4);
      expect(cubit.state.images, ['https://cdn/x.jpg']);

      cubit.setRating(2);
      await cubit.submit(title: 'Nice', comment: 'Scratched');
      verify(
        () => remote.update(
          ReviewKind.product,
          'r-1',
          rating: 2,
          title: 'Nice',
          comment: 'Scratched',
          images: const ['https://cdn/x.jpg'],
        ),
      ).called(1);
      expect(cubit.state.doneMessage, 'Review updated');
    });

    test('a review gone from my list cannot be edited', () async {
      when(() => remote.mine(ReviewKind.product)).thenAnswer((_) async => []);
      await cubit.start(
        const ReviewFormArgs(
          kind: ReviewKind.product,
          subject: 'Watch',
          reviewUuid: 'r-1',
        ),
      );
      expect(cubit.state.loadError, 'This review is no longer available.');
    });

    test('past the edit window only delete is allowed', () async {
      when(() => remote.delete(any(), any())).thenAnswer((_) async {});
      const old = Review(
        kind: ReviewKind.product,
        uuid: 'r-9',
        rating: 3,
        canEdit: false,
      );
      await cubit.start(
        const ReviewFormArgs(
          kind: ReviewKind.product,
          subject: 'Watch',
          review: old,
        ),
      );
      expect(cubit.state.canSave, isFalse);
      await cubit.delete();
      verify(() => remote.delete(ReviewKind.product, 'r-9')).called(1);
      expect(cubit.state.doneMessage, 'Review deleted');
    });
  });

  test('ProductReviewsCubit pages until every review is loaded', () async {
    final remote = _MockRemote();
    when(
      () => remote.summary('p-1'),
    ).thenAnswer((_) async => const ReviewSummary(totalReviews: 6));
    when(() => remote.productReviews('p-1', page: 1, limit: 5)).thenAnswer(
      (_) async => (items: List.filled(5, _productReview), total: 6),
    );
    when(
      () => remote.productReviews('p-1', page: 2, limit: 5),
    ).thenAnswer((_) async => (items: [_productReview], total: 6));

    final cubit = ProductReviewsCubit(remote);
    await cubit.load('p-1');
    expect(cubit.state.reviews, hasLength(5));
    expect(cubit.state.hasMore, isTrue);
    await cubit.loadMore();
    expect(cubit.state.reviews, hasLength(6));
    expect(cubit.state.hasMore, isFalse);
    await cubit.close();
  });
}
