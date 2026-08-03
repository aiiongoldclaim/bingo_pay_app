# Wallet Checkout BIGOD Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate Buy Now / Cart wallet checkout in `the_vaults_customer` off the internal, leaked-key `balance/operation` endpoint onto the backend's atomic `bigod/intent` + `bigod/confirm` flow, fix Cash-on-Delivery silently debiting the wallet, and retire the dead legacy checkout path in `the_vaults_backend`.

**Architecture:** `PaymentMethodCubit.makePayment()` branches on the selected payment method. WALLET calls a new `BigodPaymentDataSource` (JWT-authenticated, no API key) that creates a payment intent then immediately confirms it — one atomic backend transaction creates the order and moves money together, so there is no window where money moves with no order, and no synthetic fallback order id is ever needed. COD calls the existing generic `/api/v1/orders` endpoint directly with no wallet call at all. On the backend, the dead `/api/v1/checkout` module (which never actually charged anything) is deleted, and the leaked internal API key is rotated.

**Tech Stack:** Flutter/Dart (flutter_bloc, dio, get_it/injectable, mocktail, bloc_test) for `the_vaults_customer`; NestJS/TypeScript (Prisma, Jest) for `the_vaults_backend` on branch `aditya`.

## Global Constraints

- Customer app repo root: `/Users/nishant/Projects/the_vaults/the_vaults_customer`. Backend repo root: `/Users/nishant/Projects/the_vaults/the_vaults_backend` (must be on branch `aditya`, up to date with `origin/aditya` — verify with `git branch --show-current` before starting backend tasks).
- Backend package name is `multi_vendor_backend` (NestJS). Before running `npm run build` or Jest for the first time in a session, run `npx prisma generate` — the generated Prisma client is not committed and TypeScript compilation fails without it (unrelated pre-existing gap, not something to fix here).
- Never reintroduce the string `mysecreate-key` or the literal `13.159.7.199` base URL inside `lib/features/payment` or `lib/features/scanner` — those are exactly the leak this plan removes.
- No emulator/device is available in this environment. Verification for Flutter tasks is `flutter analyze` plus `flutter test <file>` for the specific test file each task adds — not a full app run.
- Every task's tests must pass before moving to the next task.

---

## Task 1: Delete the dead `/api/v1/checkout` backend module

**Repo:** `the_vaults_backend` (branch `aditya`)

**Files:**
- Delete: `src/modules/checkout/checkout.controller.ts`
- Delete: `src/modules/checkout/checkout.service.ts`
- Delete: `src/modules/checkout/checkout.module.ts`
- Delete: `src/modules/checkout/dto/checkout.module.ts`
- Modify: `src/app.module.ts:30` (remove `import { CheckoutModule } from './modules/checkout/checkout.module';`)
- Modify: `src/app.module.ts:124` (remove the `CheckoutModule,` entry from the imports array)

**Interfaces:**
- Produces: nothing — this is a pure deletion. Confirmed by `grep -rn "CheckoutService\|CheckoutModule\|CheckoutController" src --include="*.ts"` that these classes are referenced nowhere outside their own folder except the two `app.module.ts` lines above.

- [ ] **Step 1: Confirm nothing else depends on the checkout module**

Run: `cd /Users/nishant/Projects/the_vaults/the_vaults_backend && grep -rn "CheckoutService\|CheckoutModule\|CheckoutController" src --include="*.ts"`
Expected: only `src/app.module.ts:30` and `src/app.module.ts:124` (plus the files inside `src/modules/checkout/` themselves).

- [ ] **Step 2: Capture the current test baseline**

Run: `npx prisma generate && npx jest src/modules/payments src/modules/orders 2>&1 | tail -15`
Expected: all suites pass (baseline before the deletion — confirmed 7 suites / 62 tests passing under `src/modules/payments` as of this plan's writing).

- [ ] **Step 3: Delete the checkout module files**

```bash
git rm -r src/modules/checkout
```

- [ ] **Step 4: Remove the checkout import and registration from app.module.ts**

In `src/app.module.ts`, delete this line (around line 30):
```ts
import { CheckoutModule } from './modules/checkout/checkout.module';
```

And delete this line from the `imports: [...]` array (around line 124):
```ts
    CheckoutModule,
```

- [ ] **Step 5: Verify the backend still compiles**

Run: `npm run build`
Expected: `nest build` completes with no errors (no dangling references to the deleted module).

- [ ] **Step 6: Re-run the payments/orders test suites**

Run: `npx jest src/modules/payments src/modules/orders 2>&1 | tail -15`
Expected: same pass count as Step 2 — the deletion touched nothing these suites exercise.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "fix(checkout): delete dead /api/v1/checkout module

Never actually charged anything (hardcoded gateway: 'PAYTM', orders stuck
PENDING forever) and is fully superseded by the bigod intent/confirm flow
and the generic /api/v1/orders endpoint for COD."
```

---

## Task 2: Rotate the leaked `INTERNAL_API_KEY`

**Repo:** `the_vaults_backend` (branch `aditya`)

**Files:**
- Modify: `.env` (local, gitignored — line 14: `INTERNAL_API_KEY=mysecreate-key`)

**Interfaces:**
- Produces: nothing consumed by later tasks in this plan. This step invalidates the leaked value server-side; the app-side removal of all references to it happens in Tasks 5 and 7.

- [ ] **Step 1: Generate a new random key**

Run: `openssl rand -hex 32`
Record the output — this is the new key value.

- [ ] **Step 2: Replace the value in `.env`**

In `the_vaults_backend/.env`, change:
```
INTERNAL_API_KEY=mysecreate-key
```
to:
```
INTERNAL_API_KEY=<the value generated in Step 1>
```

- [ ] **Step 3: Verify the guard still reads it correctly**

Run: `npx jest src/modules/customers 2>&1 | tail -15` (if this suite doesn't exist, run `npm run start:dev` briefly and confirm no `UnauthorizedException: Internal API key is not configured` on boot, then stop it)
Expected: no errors related to `INTERNAL_API_KEY` being missing or malformed.

- [ ] **Step 4: Note for deployment**

This `.env` file is local and gitignored — it is not part of any commit. **Tell whoever manages the actual deployed backend's environment (the server behind the app's configured API host) to apply the same new `INTERNAL_API_KEY` value there and restart the service.** Until that happens, the rotation only takes effect on this local checkout, not in the running system the leaked key can currently reach.

No commit for this task (`.env` is gitignored).

---

## Task 3: BIGOD intent/confirm response models and data source

**Repo:** `the_vaults_customer`

**Files:**
- Create: `lib/features/payment/data/models/bigod_intent_response.dart`
- Create: `lib/features/payment/data/models/bigod_confirm_response.dart`
- Create: `lib/features/payment/data/bigod_payment_datasource.dart`
- Test: `test/features/payment/data/bigod_payment_datasource_test.dart`
- Modify: `lib/core/api/api_endpoints.dart` (add two constants)

**Interfaces:**
- Produces: `BigodPaymentDataSource.createIntent({required String addressId, String? variantUuid, int? quantity}) -> Future<BigodIntentResponse>`; `BigodPaymentDataSource.confirmPayment(String token) -> Future<BigodConfirmResponse>`. `BigodIntentResponse` has `token` (String), `amount` (double), `breakdown` (`BigodIntentBreakdown` with `subtotal`/`discount`/`tax`/`shipping`/`total`, all double), `customerBalance` (double?). `BigodConfirmResponse` has `status` (String), `amount` (double), `order` (`BigodOrderRef` with `uuid`/`orderNumber`, both String), `balance` (double). Task 5 consumes all of this.

- [ ] **Step 1: Add the endpoint constants**

In `lib/core/api/api_endpoints.dart`, add these two lines inside the `ApiEndpoints` class (leave everything else, including `scanner`, untouched for now — it is removed in Task 7):

```dart
  static const String bigodIntent = '/api/v1/payments/bigod/intent';
  static const String bigodConfirm = '/api/v1/payments/bigod/confirm';
```

- [ ] **Step 2: Write the response models**

Create `lib/features/payment/data/models/bigod_intent_response.dart`:

```dart
class BigodIntentBreakdown {
  final double subtotal;
  final double discount;
  final double tax;
  final double shipping;
  final double total;

  const BigodIntentBreakdown({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.shipping,
    required this.total,
  });

  factory BigodIntentBreakdown.fromJson(Map<String, dynamic> json) {
    return BigodIntentBreakdown(
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}

class BigodIntentResponse {
  final String token;
  final double amount;
  final BigodIntentBreakdown breakdown;
  final double? customerBalance;

  const BigodIntentResponse({
    required this.token,
    required this.amount,
    required this.breakdown,
    required this.customerBalance,
  });

  // API shape: { success, statusCode, message, data: { message, data: {
  //   token, amount, breakdown: {...}, customerBalance, ... } }, timestamp }
  factory BigodIntentResponse.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>? ?? const {};
    final inner = outer['data'] as Map<String, dynamic>? ?? outer;
    return BigodIntentResponse(
      token: inner['token'] as String,
      amount: (inner['amount'] as num).toDouble(),
      breakdown: BigodIntentBreakdown.fromJson(
        inner['breakdown'] as Map<String, dynamic>,
      ),
      customerBalance: (inner['customerBalance'] as num?)?.toDouble(),
    );
  }
}
```

Create `lib/features/payment/data/models/bigod_confirm_response.dart`:

```dart
class BigodOrderRef {
  final String uuid;
  final String orderNumber;

  const BigodOrderRef({required this.uuid, required this.orderNumber});

  factory BigodOrderRef.fromJson(Map<String, dynamic> json) {
    return BigodOrderRef(
      uuid: json['uuid'] as String,
      orderNumber: json['orderNumber'] as String,
    );
  }
}

class BigodConfirmResponse {
  final String status;
  final double amount;
  final BigodOrderRef order;
  final double balance;

  const BigodConfirmResponse({
    required this.status,
    required this.amount,
    required this.order,
    required this.balance,
  });

  // API shape: { success, statusCode, message, data: { message, data: {
  //   status, amount, order: { uuid, orderNumber }, balance, ... } }, timestamp }
  factory BigodConfirmResponse.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>? ?? const {};
    final inner = outer['data'] as Map<String, dynamic>? ?? outer;
    return BigodConfirmResponse(
      status: inner['status'] as String,
      amount: (inner['amount'] as num).toDouble(),
      order: BigodOrderRef.fromJson(inner['order'] as Map<String, dynamic>),
      balance: (inner['balance'] as num).toDouble(),
    );
  }
}
```

- [ ] **Step 3: Write the failing test for the data source**

Create `test/features/payment/data/bigod_payment_datasource_test.dart`:

```dart
import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late BigodPaymentDataSource dataSource;

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = BigodPaymentDataSource(mockApiClient);
  });

  // Note: Dart's Map has no structural `==`, so `when()`/`verify()` cannot
  // match a literal map like `data: {'addressId': '12'}` against the real
  // call's map instance — they'd be different objects and never match. Stub
  // with `any(named: 'data')` and assert the exact payload separately via
  // `captureAny` + `expect` (whose default matcher does deep-compare Maps).
  test('createIntent posts to ApiEndpoints.bigodIntent and parses the nested envelope', () async {
    when(() => mockDio.post(
          ApiEndpoints.bigodIntent,
          data: any(named: 'data'),
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiEndpoints.bigodIntent),
        statusCode: 201,
        data: {
          'success': true,
          'statusCode': 201,
          'message': 'Success',
          'data': {
            'message': 'Payment intent created',
            'data': {
              'token': 'a' * 64,
              'amount': 1532.82,
              'breakdown': {
                'subtotal': 1299,
                'discount': 0,
                'tax': 233.82,
                'shipping': 0,
                'total': 1532.82,
                'tokenRate': 1,
              },
              'customerBalance': 5000,
            },
          },
          'timestamp': '2026-07-15T10:30:00.000Z',
        },
      ),
    );

    final result = await dataSource.createIntent(
      addressId: '12',
      variantUuid: 'v1',
      quantity: 1,
    );

    expect(result.token, 'a' * 64);
    expect(result.amount, 1532.82);
    expect(result.breakdown.total, 1532.82);
    expect(result.customerBalance, 5000);

    final captured = verify(() => mockDio.post(
          ApiEndpoints.bigodIntent,
          data: captureAny(named: 'data'),
        )).captured.single;
    expect(captured, {'addressId': '12', 'variantUuid': 'v1', 'quantity': 1});
  });

  test('confirmPayment posts to ApiEndpoints.bigodConfirm and parses the nested envelope', () async {
    when(() => mockDio.post(
          ApiEndpoints.bigodConfirm,
          data: any(named: 'data'),
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiEndpoints.bigodConfirm),
        statusCode: 201,
        data: {
          'success': true,
          'statusCode': 201,
          'message': 'Success',
          'data': {
            'message': 'Payment successful',
            'data': {
              'status': 'PAID',
              'amount': 1532.82,
              'order': {'uuid': 'd4e5f6a7', 'orderNumber': 'ORD-123'},
              'balance': 3467.18,
            },
          },
          'timestamp': '2026-07-15T10:33:12.000Z',
        },
      ),
    );

    final result = await dataSource.confirmPayment('a' * 64);

    expect(result.status, 'PAID');
    expect(result.order.orderNumber, 'ORD-123');
    expect(result.balance, 3467.18);

    final captured = verify(() => mockDio.post(
          ApiEndpoints.bigodConfirm,
          data: captureAny(named: 'data'),
        )).captured.single;
    expect(captured, {'token': 'a' * 64});
  });
}
```

- [ ] **Step 4: Run the test to verify it fails**

Run: `flutter test test/features/payment/data/bigod_payment_datasource_test.dart`
Expected: FAIL — `bigod_payment_datasource.dart` doesn't exist yet (import error).

- [ ] **Step 5: Write the data source**

Create `lib/features/payment/data/bigod_payment_datasource.dart`:

```dart
import 'package:injectable/injectable.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'models/bigod_confirm_response.dart';
import 'models/bigod_intent_response.dart';

@singleton
class BigodPaymentDataSource {
  final ApiClient _client;

  const BigodPaymentDataSource(this._client);

  Future<BigodIntentResponse> createIntent({
    required String addressId,
    String? variantUuid,
    int? quantity,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.bigodIntent,
      data: {
        'addressId': addressId,
        if (variantUuid != null) 'variantUuid': variantUuid,
        if (quantity != null) 'quantity': quantity,
      },
    );
    return BigodIntentResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BigodConfirmResponse> confirmPayment(String token) async {
    final response = await _client.dio.post(
      ApiEndpoints.bigodConfirm,
      data: {'token': token},
    );
    return BigodConfirmResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
```

- [ ] **Step 6: Run the test to verify it passes**

Run: `flutter test test/features/payment/data/bigod_payment_datasource_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 7: Regenerate DI registrations**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: completes with no errors; `lib/core/di/injection.config.dart` now registers `BigodPaymentDataSource` as a singleton.

- [ ] **Step 8: Commit**

```bash
git add lib/core/api/api_endpoints.dart lib/features/payment/data/models/bigod_intent_response.dart lib/features/payment/data/models/bigod_confirm_response.dart lib/features/payment/data/bigod_payment_datasource.dart lib/core/di/injection.config.dart test/features/payment/data/bigod_payment_datasource_test.dart
git commit -m "feat(payment): add BIGOD intent/confirm data source

Foundational piece for migrating wallet checkout off the internal
balance-operation endpoint; not wired into the cubit yet."
```

---

## Task 4: Fix Cash-on-Delivery to skip the wallet entirely

**Repo:** `the_vaults_customer`

**Files:**
- Modify: `lib/features/payment/presentation/cubit/payment_cubit.dart` (add `_placeCodOrder()`, branch `makePayment()`)
- Test: `test/features/payment/presentation/cubit/payment_cubit_cod_test.dart`

**Interfaces:**
- Consumes: `ApiEndpoints.orders` (existing), `PaymentMethod.cashOnDelivery` (existing enum value), `state.selectedMethod`/`state.isCartFlow`/`state.deliveryAddressId`/`state.variantUuid`/`state.quantity`/`state.couponCode`/`state.notes` (existing state fields).
- Produces: `PaymentMethodCubit._placeCodOrder() -> Future<String>` (throws on failure — no more silent `null` swallow). `makePayment()` now short-circuits to this method when `selectedMethod == PaymentMethod.cashOnDelivery`, before the existing (still unchanged in this task) wallet logic runs.

Currently, selecting Cash on Delivery has no effect — `makePayment()` always runs the wallet-debit path regardless of `state.selectedMethod`. This task fixes that; the wallet path itself is rewritten in Task 5.

- [ ] **Step 1: Write the failing test**

Create `test/features/payment/presentation/cubit/payment_cubit_cod_test.dart`:

```dart
import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    GetIt.I.registerSingleton<ApiClient>(mockApiClient);
  });

  tearDown(() {
    GetIt.I.unregister<ApiClient>();
  });

  PaymentMethodCubit buildCubit() {
    return PaymentMethodCubit(
      productPrice: 100,
      userEmail: 'buyer@example.com',
      vendorEmail: 'vendor@example.com',
      variantUuid: 'variant-1',
    )
      ..updateDeliveryAddress(
        name: 'Jane',
        phone: '555',
        address: '1 Road',
        city: 'City',
        postal: '00000',
        addressId: '12',
      )
      ..selectPaymentMethod(PaymentMethod.cashOnDelivery);
  }

  // Note: Dart's Map has no structural `==`, so the stub below matches any
  // `data` map and the exact payload is asserted separately via `captureAny`
  // + `expect` (see Task 3's data source test for the same reasoning).
  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'places a COD order via /api/v1/orders without ever calling the balance-operation endpoint',
    build: () {
      when(() => mockDio.post(
            ApiEndpoints.orders,
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.orders),
          statusCode: 201,
          data: {
            'data': {'orderNumber': 'ORD-COD-1'},
          },
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.loading)
          .having((s) => s.isProcessing, 'isProcessing', true),
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.success)
          .having((s) => s.orderId, 'orderId', 'ORD-COD-1')
          .having((s) => s.isProcessing, 'isProcessing', false),
    ],
    verify: (_) {
      verifyNever(
        () => mockDio.post('/api/v1/customers/bingopay/balance/operation',
            data: any(named: 'data')),
      );
      final captured = verify(() => mockDio.post(
            ApiEndpoints.orders,
            data: captureAny(named: 'data'),
          )).captured.single;
      expect(captured, {
        'addressId': '12',
        'paymentMethod': 'COD',
        'variantUuid': 'variant-1',
        'quantity': 1,
      });
    },
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'surfaces a failure if the order request itself fails, with no fake order id',
    build: () {
      when(() => mockDio.post(
            ApiEndpoints.orders,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.orders),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.orders),
            statusCode: 400,
            data: {'message': 'Address not found'},
          ),
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.loading),
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.failure)
          .having((s) => s.orderId, 'orderId', 'BG-48231'), // untouched default — never fabricated
    ],
  );
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/payment/presentation/cubit/payment_cubit_cod_test.dart`
Expected: FAIL — `makePayment()` still always runs the wallet-debit path, so it calls the balance-operation endpoint (the `verifyNever` in the first test fails) and the second test's failure path doesn't match either.

- [ ] **Step 3: Add `_placeCodOrder()` and branch `makePayment()`**

In `lib/features/payment/presentation/cubit/payment_cubit.dart`, add this new method (near `_createOrder`/`_checkout`, which it will replace in Task 5 — leave those two methods in place for now):

```dart
  Future<String> _placeCodOrder() async {
    final client = GetIt.I<ApiClient>();
    final response = await client.dio.post(
      ApiEndpoints.orders,
      data: {
        'addressId': state.deliveryAddressId,
        'paymentMethod': 'COD',
        if (!state.isCartFlow) 'variantUuid': state.variantUuid,
        if (!state.isCartFlow) 'quantity': state.quantity,
        if (!state.isCartFlow && state.couponCode.isNotEmpty)
          'couponCode': state.couponCode,
        if (!state.isCartFlow && state.notes.isNotEmpty) 'notes': state.notes,
      },
    );
    final orderId = _extractOrderId(response.data);
    if (orderId == null) {
      throw StateError('Order was created but the response had no order id');
    }
    return orderId;
  }
```

Then, at the very top of the existing `try {` block inside `makePayment()` (before the `if (state.isCartFlow) {` line that starts the old wallet logic), add:

```dart
      if (state.selectedMethod == PaymentMethod.cashOnDelivery) {
        final orderId = await _placeCodOrder();
        emit(
          state.copyWith(
            status: PaymentStatus.success,
            isProcessing: false,
            orderId: orderId,
          ),
        );
        return;
      }

```

Leave everything else in the method (the `dio`/`ts` setup above the `try`, the existing `if (state.isCartFlow) {...} else {...}` wallet block, and the two `on DioException catch` / `catch (_)` handlers) exactly as-is — Task 5 replaces the wallet block.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/payment/presentation/cubit/payment_cubit_cod_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/payment/presentation/cubit/payment_cubit.dart test/features/payment/presentation/cubit/payment_cubit_cod_test.dart
git commit -m "fix(payment): stop debiting the wallet when Cash on Delivery is selected

makePayment() previously ignored selectedMethod entirely and always ran the
wallet-debit path. COD now goes straight to /api/v1/orders with no balance
call, and a failed order request is a real failure instead of a swallowed
null."
```

---

## Task 5: Replace the wallet path with BIGOD intent/confirm

**Repo:** `the_vaults_customer`

**Files:**
- Modify: `lib/features/payment/presentation/cubit/payment_cubit.dart` (replace wallet branch, delete `_apiUrl`/`_apiKey`/`_resolveVendorEmail`/`_createOrder`/`_checkout`)
- Test: `test/features/payment/presentation/cubit/payment_cubit_wallet_test.dart`

**Interfaces:**
- Consumes: `BigodPaymentDataSource` (Task 3): `createIntent({addressId, variantUuid, quantity}) -> Future<BigodIntentResponse>`, `confirmPayment(token) -> Future<BigodConfirmResponse>`. `BigodIntentResponse.{token, amount, customerBalance}`, `BigodConfirmResponse.{order.orderNumber}`.
- Produces: `PaymentMethodCubit` now accepts an optional named `bigodPaymentDataSource` constructor parameter (defaults to `GetIt.I<BigodPaymentDataSource>()`), used by later tasks' tests.

- [ ] **Step 1: Write the failing tests**

Create `test/features/payment/presentation/cubit/payment_cubit_wallet_test.dart`:

```dart
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/data/models/bigod_confirm_response.dart';
import 'package:bingo_pay/features/payment/data/models/bigod_intent_response.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBigodPaymentDataSource extends Mock implements BigodPaymentDataSource {}

void main() {
  late MockBigodPaymentDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockBigodPaymentDataSource();
  });

  PaymentMethodCubit buildCubit() {
    return PaymentMethodCubit(
      productPrice: 100,
      userEmail: 'buyer@example.com',
      vendorEmail: 'vendor@example.com',
      variantUuid: 'variant-1',
      bigodPaymentDataSource: mockDataSource,
    )..updateDeliveryAddress(
        name: 'Jane',
        phone: '555',
        address: '1 Road',
        city: 'City',
        postal: '00000',
        addressId: '12',
      );
  }

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'creates an intent, confirms it, and emits success with the real order number',
    build: () {
      when(() => mockDataSource.createIntent(
            addressId: '12',
            variantUuid: 'variant-1',
            quantity: 1,
          )).thenAnswer(
        (_) async => const BigodIntentResponse(
          token: 'tok-123',
          amount: 100,
          breakdown: BigodIntentBreakdown(
            subtotal: 100,
            discount: 0,
            tax: 0,
            shipping: 0,
            total: 100,
          ),
          customerBalance: 500,
        ),
      );
      when(() => mockDataSource.confirmPayment('tok-123')).thenAnswer(
        (_) async => const BigodConfirmResponse(
          status: 'PAID',
          amount: 100,
          order: BigodOrderRef(uuid: 'o-uuid', orderNumber: 'ORD-1'),
          balance: 400,
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.loading)
          .having((s) => s.isProcessing, 'isProcessing', true),
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.success)
          .having((s) => s.orderId, 'orderId', 'ORD-1')
          .having((s) => s.isProcessing, 'isProcessing', false),
    ],
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'fails fast without confirming when the intent reports insufficient balance',
    build: () {
      when(() => mockDataSource.createIntent(
            addressId: '12',
            variantUuid: 'variant-1',
            quantity: 1,
          )).thenAnswer(
        (_) async => const BigodIntentResponse(
          token: 'tok-123',
          amount: 100,
          breakdown: BigodIntentBreakdown(
            subtotal: 100,
            discount: 0,
            tax: 0,
            shipping: 0,
            total: 100,
          ),
          customerBalance: 10,
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.loading),
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', contains('Insufficient')),
    ],
    verify: (_) {
      verifyNever(() => mockDataSource.confirmPayment(any()));
    },
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'omits variantUuid and quantity from the intent request for a cart checkout',
    build: () {
      when(() => mockDataSource.createIntent(
            addressId: '12',
            variantUuid: null,
            quantity: null,
          )).thenAnswer(
        (_) async => const BigodIntentResponse(
          token: 'tok-cart',
          amount: 200,
          breakdown: BigodIntentBreakdown(
            subtotal: 200,
            discount: 0,
            tax: 0,
            shipping: 0,
            total: 200,
          ),
          customerBalance: 500,
        ),
      );
      when(() => mockDataSource.confirmPayment('tok-cart')).thenAnswer(
        (_) async => const BigodConfirmResponse(
          status: 'PAID',
          amount: 200,
          order: BigodOrderRef(uuid: 'o-uuid-2', orderNumber: 'ORD-2'),
          balance: 300,
        ),
      );
      final cartItem = CartItemEntity(
        id: 1,
        quantity: 2,
        unitPrice: 100,
        totalPrice: 200,
        product: const CartProductEntity(uuid: 'p1', title: 'Widget', slug: 'widget'),
        variant: const CartVariantEntity(uuid: 'v1', sku: 'W-1', stock: 10),
        vendor: const CartVendorEntity(uuid: 've1', shopName: 'Acme'),
      );
      return PaymentMethodCubit(
        userEmail: 'buyer@example.com',
        vendorEmail: 'vendor@example.com',
        bigodPaymentDataSource: mockDataSource,
        cartItems: [cartItem],
      )..updateDeliveryAddress(
          name: 'Jane',
          phone: '555',
          address: '1 Road',
          city: 'City',
          postal: '00000',
          addressId: '12',
        );
    },
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.loading),
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.success)
          .having((s) => s.orderId, 'orderId', 'ORD-2'),
    ],
  );
}
```

Add this import alongside the others at the top of the file for the `CartItemEntity` fixture used above:
```dart
import 'package:bingo_pay/features/cart/domain/entities/cart_item_entity.dart';
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/features/payment/presentation/cubit/payment_cubit_wallet_test.dart`
Expected: FAIL — compile error, since `PaymentMethodCubit` doesn't yet accept a `bigodPaymentDataSource` parameter.

- [ ] **Step 3: Rewrite the wallet branch**

In `lib/features/payment/presentation/cubit/payment_cubit.dart`:

Add the import:
```dart
import '../../data/bigod_payment_datasource.dart';
import '../../data/models/bigod_confirm_response.dart';
import '../../data/models/bigod_intent_response.dart';
```

Change the constructor to accept the new dependency:

```dart
class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  PaymentMethodCubit({
    double productPrice = 0.0,
    String productName = '',
    String userEmail = '',
    String vendorEmail = '',
    String? variantUuid,
    int quantity = 1,
    List<CartItemEntity> cartItems = const [],
    BigodPaymentDataSource? bigodPaymentDataSource,
  })  : _bigodPaymentDataSource =
            bigodPaymentDataSource ?? GetIt.I<BigodPaymentDataSource>(),
        super(
          PaymentMethodState.initial(
            productPrice: productPrice,
            productName: productName,
            userEmail: userEmail,
            vendorEmail: vendorEmail,
            variantUuid: variantUuid,
            quantity: quantity,
            cartItems: cartItems,
          ),
        );

  final BigodPaymentDataSource _bigodPaymentDataSource;
```

Delete these members entirely: `_apiUrl`, `_apiKey`, `_resolveVendorEmail`, `_createOrder`, `_checkout` (all fully superseded — `_placeCodOrder` from Task 4 replaces `_createOrder`/`_checkout`'s job for COD, and the wallet path no longer creates an order separately at all).

Replace the body of `makePayment()` (keep the COD branch from Task 4 unchanged at the top) with:

```dart
  Future<void> makePayment() async {
    emit(state.copyWith(status: PaymentStatus.loading, isProcessing: true));

    try {
      if (state.selectedMethod == PaymentMethod.cashOnDelivery) {
        final orderId = await _placeCodOrder();
        emit(
          state.copyWith(
            status: PaymentStatus.success,
            isProcessing: false,
            orderId: orderId,
          ),
        );
        return;
      }

      final intent = await _bigodPaymentDataSource.createIntent(
        addressId: state.deliveryAddressId,
        variantUuid: state.isCartFlow ? null : state.variantUuid,
        quantity: state.isCartFlow ? null : state.quantity,
      );

      if (intent.customerBalance != null &&
          intent.customerBalance! < intent.amount) {
        emit(
          state.copyWith(
            status: PaymentStatus.failure,
            errorMessage: 'Insufficient BingoPay balance for this purchase.',
            isProcessing: false,
          ),
        );
        return;
      }

      final confirmation =
          await _bigodPaymentDataSource.confirmPayment(intent.token);

      emit(
        state.copyWith(
          status: PaymentStatus.success,
          isProcessing: false,
          orderId: confirmation.order.orderNumber,
        ),
      );
    } on DioException catch (e) {
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: _messageFor(e),
          isProcessing: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: 'Payment failed. Please try again.',
          isProcessing: false,
        ),
      );
    }
  }

  String _messageFor(DioException e) {
    final failure = ErrorHandler.mapExceptionToFailure(e);
    if (failure is ServerFailure && failure.statusCode == 409) {
      return 'This payment was already processed.';
    }
    return failure.message;
  }
```

Add the import for `ErrorHandler`/`ServerFailure`:
```dart
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/features/payment/presentation/cubit/payment_cubit_wallet_test.dart test/features/payment/presentation/cubit/payment_cubit_cod_test.dart`
Expected: PASS for all tests (both the new wallet tests and Task 4's COD tests, which must still pass unchanged).

- [ ] **Step 5: Run `flutter analyze` on the touched file**

Run: `flutter analyze lib/features/payment/presentation/cubit/payment_cubit.dart`
Expected: no errors (unused-import/unused-element warnings for anything left over from the deleted methods must be resolved).

- [ ] **Step 6: Commit**

```bash
git add lib/features/payment/presentation/cubit/payment_cubit.dart test/features/payment/presentation/cubit/payment_cubit_wallet_test.dart
git commit -m "fix(payment): route wallet checkout through bigod intent/confirm

Replaces the direct calls to the internal, leaked-key balance-operation
endpoint with the backend's atomic bigod/intent + bigod/confirm flow.
Deletes the hardcoded API key/IP, the per-item vendor-email resolution
hack, and the synthetic BG-<timestamp> fallback order id — a failed
confirm is now always a real failure."
```

---

## Task 6: Clear the cart after a successful purchase

**Repo:** `the_vaults_customer`

**Files:**
- Modify: `lib/features/payment/presentation/cubit/payment_cubit.dart`
- Test: `test/features/payment/presentation/cubit/payment_cubit_cart_clear_test.dart`

**Interfaces:**
- Consumes: `ClearCartUseCase.call() -> Future<Either<Failure, String>>` (existing, currently unused — see `lib/features/cart/domain/usecases/clear_cart_usecase.dart`).
- Produces: `PaymentMethodCubit` now also accepts an optional named `clearCartUseCase` constructor parameter (defaults to `GetIt.I<ClearCartUseCase>()`).

TC-CHK-003 requires the cart to be cleared after a successful order; today nothing calls `ClearCartUseCase` anywhere.

- [ ] **Step 1: Write the failing test**

Create `test/features/payment/presentation/cubit/payment_cubit_cart_clear_test.dart`:

```dart
import 'package:bingo_pay/features/cart/domain/entities/cart_item_entity.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/data/models/bigod_confirm_response.dart';
import 'package:bingo_pay/features/payment/data/models/bigod_intent_response.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockBigodPaymentDataSource extends Mock implements BigodPaymentDataSource {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

CartItemEntity _cartItem() => const CartItemEntity(
      id: 1,
      quantity: 1,
      unitPrice: 50,
      totalPrice: 50,
      product: CartProductEntity(uuid: 'p1', title: 'Widget', slug: 'widget'),
      variant: CartVariantEntity(uuid: 'v1', sku: 'W-1', stock: 10),
      vendor: CartVendorEntity(uuid: 've1', shopName: 'Acme'),
    );

void main() {
  late MockBigodPaymentDataSource mockDataSource;
  late MockClearCartUseCase mockClearCart;

  setUp(() {
    mockDataSource = MockBigodPaymentDataSource();
    mockClearCart = MockClearCartUseCase();
    when(() => mockClearCart()).thenAnswer((_) async => const Right('cleared'));
    when(() => mockDataSource.createIntent(
          addressId: any(named: 'addressId'),
          variantUuid: any(named: 'variantUuid'),
          quantity: any(named: 'quantity'),
        )).thenAnswer(
      (_) async => const BigodIntentResponse(
        token: 'tok',
        amount: 50,
        breakdown: BigodIntentBreakdown(
          subtotal: 50,
          discount: 0,
          tax: 0,
          shipping: 0,
          total: 50,
        ),
        customerBalance: 500,
      ),
    );
    when(() => mockDataSource.confirmPayment('tok')).thenAnswer(
      (_) async => const BigodConfirmResponse(
        status: 'PAID',
        amount: 50,
        order: BigodOrderRef(uuid: 'o-uuid', orderNumber: 'ORD-1'),
        balance: 450,
      ),
    );
  });

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'clears the cart after a successful cart wallet purchase',
    build: () => PaymentMethodCubit(
      userEmail: 'buyer@example.com',
      vendorEmail: 'vendor@example.com',
      cartItems: [_cartItem()],
      bigodPaymentDataSource: mockDataSource,
      clearCartUseCase: mockClearCart,
    )..updateDeliveryAddress(
        name: 'Jane',
        phone: '555',
        address: '1 Road',
        city: 'City',
        postal: '00000',
        addressId: '12',
      ),
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.loading),
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.success),
    ],
    verify: (_) {
      verify(() => mockClearCart()).called(1);
    },
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'does not attempt to clear the cart for a buy-now (non-cart) purchase',
    build: () => PaymentMethodCubit(
      userEmail: 'buyer@example.com',
      vendorEmail: 'vendor@example.com',
      variantUuid: 'variant-1',
      bigodPaymentDataSource: mockDataSource,
      clearCartUseCase: mockClearCart,
    )..updateDeliveryAddress(
        name: 'Jane',
        phone: '555',
        address: '1 Road',
        city: 'City',
        postal: '00000',
        addressId: '12',
      ),
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.loading),
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.success),
    ],
    verify: (_) {
      verifyNever(() => mockClearCart());
    },
  );
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/payment/presentation/cubit/payment_cubit_cart_clear_test.dart`
Expected: FAIL — compile error, `PaymentMethodCubit` doesn't accept `clearCartUseCase` yet.

- [ ] **Step 3: Wire in `ClearCartUseCase`**

In `lib/features/payment/presentation/cubit/payment_cubit.dart`, add the import:
```dart
import '../../../cart/domain/usecases/clear_cart_usecase.dart';
```

Extend the constructor:
```dart
  PaymentMethodCubit({
    double productPrice = 0.0,
    String productName = '',
    String userEmail = '',
    String vendorEmail = '',
    String? variantUuid,
    int quantity = 1,
    List<CartItemEntity> cartItems = const [],
    BigodPaymentDataSource? bigodPaymentDataSource,
    ClearCartUseCase? clearCartUseCase,
  })  : _bigodPaymentDataSource =
            bigodPaymentDataSource ?? GetIt.I<BigodPaymentDataSource>(),
        _clearCartUseCase = clearCartUseCase ?? GetIt.I<ClearCartUseCase>(),
        super(
          PaymentMethodState.initial(
            productPrice: productPrice,
            productName: productName,
            userEmail: userEmail,
            vendorEmail: vendorEmail,
            variantUuid: variantUuid,
            quantity: quantity,
            cartItems: cartItems,
          ),
        );

  final BigodPaymentDataSource _bigodPaymentDataSource;
  final ClearCartUseCase _clearCartUseCase;
```

Add a helper method:
```dart
  Future<void> _clearCartIfNeeded() async {
    if (!state.isCartFlow) return;
    await _clearCartUseCase(); // best-effort — a clear failure shouldn't block a completed purchase
  }
```

In `makePayment()`, call `await _clearCartIfNeeded();` immediately before **both** success emissions — the COD branch's and the wallet branch's:

```dart
      if (state.selectedMethod == PaymentMethod.cashOnDelivery) {
        final orderId = await _placeCodOrder();
        await _clearCartIfNeeded();
        emit(
          state.copyWith(
            status: PaymentStatus.success,
            isProcessing: false,
            orderId: orderId,
          ),
        );
        return;
      }
```
and
```dart
      final confirmation =
          await _bigodPaymentDataSource.confirmPayment(intent.token);

      await _clearCartIfNeeded();

      emit(
        state.copyWith(
          status: PaymentStatus.success,
          isProcessing: false,
          orderId: confirmation.order.orderNumber,
        ),
      );
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/payment/presentation/cubit/payment_cubit_cart_clear_test.dart test/features/payment/presentation/cubit/payment_cubit_wallet_test.dart test/features/payment/presentation/cubit/payment_cubit_cod_test.dart`
Expected: PASS for all tests across all three files.

- [ ] **Step 5: Remove the dead commented-out screen while touching this area**

In `lib/features/payment/presentation/screens/review_pay_screen.dart`, delete the entire commented-out block of code at the top of the file (lines 1-291 as of this plan's writing — the earlier, superseded implementation of the review/pay screen, left in as a comment). Leave the live `ReviewPayScreen` class and everything else in the file untouched.

Run: `flutter analyze lib/features/payment/presentation/screens/review_pay_screen.dart`
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add lib/features/payment/presentation/cubit/payment_cubit.dart lib/features/payment/presentation/screens/review_pay_screen.dart test/features/payment/presentation/cubit/payment_cubit_cart_clear_test.dart
git commit -m "fix(payment): clear the cart after a successful order

TC-CHK-003 requires this and nothing previously called the existing
ClearCartUseCase. Also removes a fully superseded, commented-out copy of
this screen left at the top of the file."
```

---

## Task 7: Disable the scanner's dead P2P pay flow safely

**Repo:** `the_vaults_customer`

**Files:**
- Modify: `lib/features/scanner/data/datasource/payment_remote_datasource.dart`
- Test: `test/features/scanner/data/datasource/payment_remote_datasource_test.dart`
- Modify: `lib/core/api/api_endpoints.dart` (remove the now-fully-unused `scanner` constant)

**Interfaces:**
- Produces: `PaymentRemoteDataSourceImpl.processPayment()` now always throws `ServerException` instead of making any network call.

The scanner's "scan a QR, type any amount, send" flow has no safe backend endpoint (see the design spec's Background) — its only backend dependency was the internal balance-operation endpoint whose key Task 2 rotated. Rather than touch the screen/router (out of scope — Spec 2 replaces this feature properly), make the data source itself fail cleanly. `PaymentCubit.pay()` (`lib/features/scanner/presentation/cubit/payment_cubit.dart`) already catches any `Exception`, maps it via `ErrorHandler`, and surfaces `failure.message` through the existing `PaymentFailure` state and the screen's existing SnackBar listener — so no other file needs to change for the error to reach the user.

- [ ] **Step 1: Write the failing test**

Create `test/features/scanner/data/datasource/payment_remote_datasource_test.dart`:

```dart
import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/features/scanner/data/datasource/payment_remote_datasource.dart';
import 'package:bingo_pay/features/scanner/data/models/payment_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('processPayment always throws — scan-to-pay has no safe backend endpoint until Spec 2 ships', () async {
    const dataSource = PaymentRemoteDataSourceImpl();

    await expectLater(
      () => dataSource.processPayment(
        const PaymentRequestModel(
          email: 'buyer@example.com',
          amount: 10,
          operation: 'deduct',
          reference: 'ref-1',
          description: 'desc',
        ),
      ),
      throwsA(isA<ServerException>()),
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/scanner/data/datasource/payment_remote_datasource_test.dart`
Expected: FAIL — the current implementation requires an `ApiClient` constructor argument and would attempt (and fail/error differently) a real network call rather than throwing `ServerException`.

- [ ] **Step 3: Rewrite the data source**

Replace the full contents of `lib/features/scanner/data/datasource/payment_remote_datasource.dart` with:

```dart
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/payment_request_model.dart';
import '../models/payment_response_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentResponseModel> processPayment(PaymentRequestModel request);
}

@Injectable(as: PaymentRemoteDataSource)
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  const PaymentRemoteDataSourceImpl();

  @override
  Future<PaymentResponseModel> processPayment(
    PaymentRequestModel request,
  ) async {
    throw const ServerException(
      message: 'Scan-to-pay is being upgraded and is temporarily '
          'unavailable. Please use Buy Now or Cart checkout instead.',
    );
  }
}
```

This removes the `ApiClient` dependency, the hardcoded `x-api-key: mysecreate-key` header, and the direct call to the leaked-key endpoint entirely.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/scanner/data/datasource/payment_remote_datasource_test.dart`
Expected: PASS.

- [ ] **Step 5: Remove the now-fully-unused `scanner` API endpoint constant**

Run: `grep -rn "ApiEndpoints.scanner" lib` — confirm no remaining references now that `payment_remote_datasource.dart` no longer uses it.

In `lib/core/api/api_endpoints.dart`, delete the line:
```dart
  static const String scanner = '/api/v1/customers/bingopay/balance/operation';
```
(and the commented-out line directly above it, `// static const String scanner = ...`).

- [ ] **Step 6: Regenerate DI registrations**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: completes with no errors (the `PaymentRemoteDataSourceImpl` constructor signature changed from taking an `ApiClient` to taking nothing).

- [ ] **Step 7: Confirm the leaked key is fully gone from the app**

Run: `grep -rn "mysecreate-key\|13\.159\.7\.199.*bingopay" lib`
Expected: no matches.

- [ ] **Step 8: Run the full test suite and analyze**

Run: `flutter test && flutter analyze`
Expected: all tests pass (this plan's new tests plus any pre-existing ones); no analyzer errors.

- [ ] **Step 9: Commit**

```bash
git add lib/features/scanner/data/datasource/payment_remote_datasource.dart lib/core/api/api_endpoints.dart lib/core/di/injection.config.dart test/features/scanner/data/datasource/payment_remote_datasource_test.dart
git commit -m "fix(scanner): stop calling the leaked-key balance-operation endpoint

The scan-to-pay flow has no safe backend equivalent (freeform P2P transfer
isn't a real BIGOD operation) and its only backend dependency is the
internal API key rotated away in the backend change. The data source now
fails cleanly with a clear message instead of hitting a dead/insecure
endpoint; the existing PaymentCubit error handling surfaces it as-is.
Full replacement (vendor-scoped shopping) is a separate spec."
```

---

## Plan-Level Verification

After all tasks are complete, run from `the_vaults_customer`:
```bash
flutter analyze
flutter test
```
And from `the_vaults_backend` (branch `aditya`):
```bash
npx prisma generate
npm run build
npx jest
```
All must pass with zero errors. Then manually re-check against `bingo_pay_test_cases.csv` rows TC-CHK-003/004/005, TC-PAY-003/004, TC-WAL-003 on a real device/emulator before release — this environment has none available.
