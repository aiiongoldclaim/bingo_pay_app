# TVS Wallet

TVS Wallet is TheVaults' closed-loop wallet. Members hold **TVS Coins** in their country's currency (**1 TVS Coin = 1 unit of that currency**, e.g. 1 coin = ₹1 in India). With the coins they pay shops by scanning a QR code, pay marketplace orders at checkout, pay auction wins, and send coins to other members. Coins come in from card top-ups, admin adjustments, refunds and rewards (cashback, referral, joining and top-up bonuses).

The backend (`backend/src/modules/tvs-wallet`) owns every rule in this document. The mobile app (`lib/features/tvs_wallet`, `lib/features/scanner`, `lib/features/payment`) and the web app (`frontend/src/pages/customer/tvs-wallet`, `frontend/src/pages/admin/tvs-wallet`) only display and request.

---

## Contents

1. [Concepts](#concepts)
2. [Countries & Limits](#countries--limits)
3. [Wallet Lifecycle](#wallet-lifecycle)
4. [Identity Verification (KYC)](#identity-verification-kyc)
5. [Wallet PIN (MPIN)](#wallet-pin-mpin)
6. [Money In](#money-in)
7. [Money Out](#money-out)
8. [Exchange Rates (FX)](#exchange-rates-fx)
9. [Offers & Rewards](#offers--rewards)
10. [Referrals, Partners & Commissions](#referrals-partners--commissions)
11. [Admin Console](#admin-console)
12. [Background Jobs](#background-jobs)
13. [API Reference](#api-reference)
14. [Error Codes](#error-codes)
15. [Client Screens](#client-screens)
16. [Testing](#testing)

---

## Concepts

### Wallets

| Owner | Who | Notes |
|---|---|---|
| `USER` | A customer | One **home wallet**, created `INACTIVE` on first use in the default country's currency. KYC in another country moves the home wallet to that currency; the old wallet stays usable for its own currency. |
| `VENDOR` | A shop | The **shop wallet**, separate from the owner's personal wallet. Its currency follows the country of the shop's verification. |
| `SYSTEM` | The platform | Counterparty accounts: `TOPUP:STRIPE`, `REWARDS:*` (signup, referral, cashback, promo, topup, milestone, discount), `REVENUE`, `ADJUSTMENTS`, `FX`. |

Staff accounts (`super_admin`, `admin`, `sub_admin`) never get a wallet.

**Wallet status**

| Status | Meaning |
|---|---|
| `INACTIVE` | New account, identity not verified. Can **receive** bonus coins, rewards and refunds but cannot spend, top up or send. |
| `ACTIVE` | Verified. Everything allowed within limits. |
| `FROZEN` | Held by an admin or because KYC was revoked. Only refunds and reversals can come in; nothing goes out. |

### Balance buckets

| Bucket | Shown as | Rules |
|---|---|---|
| `AVAILABLE` | Own coins | Top-ups, transfers received, refunds. Can be spent and sent. |
| `BONUS` | Bonus | Promotional coins in **lots**, each with an expiry. Spent **before** own coins, oldest expiry first. **Cannot be sent** to another member. |
| `PENDING` / `HELD` | — | Reserved for settlement and holds. |

`spendable = available + bonus`. The wallet card warns when bonus expires within 7 days ("₹50.00 bonus expires 22 Oct 2026 · used first").

### Ledger

Every movement is a **transaction** with balanced **entries** (double-entry): for each transaction and currency, credits equal debits. Each entry records the wallet, bucket, direction, amount and the balance after it. The ledger is never rewritten; mistakes are fixed with a `REVERSAL` or an adjustment.

Transaction types: `TOPUP`, `TOPUP_REFUND`, `ORDER_PAYMENT`, `ORDER_REFUND`, `AUCTION_PAYMENT`, `QR_PAYMENT`, `QR_REFUND`, `P2P_TRANSFER`, `CASHBACK`, `SIGNUP_BONUS`, `REFERRAL_REWARD`, `PROMO_BONUS`, `TOPUP_BONUS`, `MILESTONE_BONUS`, `BONUS_EXPIRY`, `REWARD_CLAWBACK`, `OFFER_DISCOUNT_SUBSIDY`, `ADMIN_CREDIT`, `ADMIN_DEBIT`, `REVERSAL`, `CONVERSION`, `SETTLEMENT_RELEASE`.

Every money-moving request carries an **idempotency key** made by the client. A retry with the same key returns the first result instead of moving money twice.

---

## Countries & Limits

Each country (`TvsCountry`, edited in **Admin → TVS Wallet → Countries**) defines:

| Setting | Purpose |
|---|---|
| `currency` | Wallet currency (`IN` → `INR`, `SG` → `SGD`, `AE` → `AED`) |
| `kycDocumentTypes`, `kycRule` | Documents a customer may use, which photos each needs (`FRONT`, `BACK`, `SELFIE`), and how many are required (`{ required: [...], pick: n }`) |
| `vendorKycDocumentTypes`, `vendorKycRule` | Same for shops. An empty list closes shop verification in that country. |
| `limits` | See below |
| `defaultBonusExpiryDays` | Expiry for bonus coins when an offer doesn't set one |
| `returnWindowDays` | Delay for "after return window" cashback |
| `storeRate` | Fallback rate: coins per 1 unit of store currency (USD) |

**Limits** (India defaults shown)

| Key | India | Applies to |
|---|---|---|
| `topupMin` / `topupMax` | ₹100 / ₹50,000 | One card top-up |
| `topupDailyMax` | ₹100,000 | Top-ups in 24 h |
| `qrPerTxnMax` | ₹50,000 | One QR payment |
| `pinAbove` | ₹2,000 | MPIN required above this amount |
| `transferPerTxnMax` | ₹10,000 *(default)* | One transfer |
| `transferDailyMax` | ₹25,000 *(default)* | Transfers in 24 h |
| `transferDailyCount` | 20 *(default)* | Transfers in 24 h |

---

## Wallet Lifecycle

```
Sign up ──► INACTIVE ──(KYC approved)──► ACTIVE ◄──(admin unfreeze)──┐
              │  receives bonus/rewards     │                          │
              │                             ├──(admin freeze)──────► FROZEN
              └─(KYC rejected: resubmit)    └──(KYC revoked)───────► FROZEN
```

- A new member's wallet starts `INACTIVE`. Bonus received before activation is kept. Offers with `expiryStartsOnActivation` start the bonus clock at activation.
- **Approval** activates the wallet and fires `tvs.kyc.approved` / `tvs.wallet.activated`, which `KYC_APPROVED` offers and referral rewards listen to.
- **Revoking** a customer's or shop's KYC freezes the matching wallet.
- Admin **freeze / unfreeze** needs a reason, which the customer sees ("Wallet on hold – Under review by support").

---

## Identity Verification (KYC)

### Customer

1. `GET /tvs-wallet/kyc/requirements` returns the country's documents, photos and number format.
2. The customer picks a document (e.g. *any 1 of Aadhaar, PAN, Passport*), enters the name exactly as printed, the document number, and their **home address** (used for area-limited offers), then uploads the photos.
3. `POST /tvs-wallet/kyc` (multipart). Files: JPEG, PNG or PDF, **5 MB each**, stored in private S3 storage.
4. An admin approves, rejects with a reason, or asks to resubmit. After **3 rejections**: "Too many rejected attempts. Please contact support."

**Document number rules.** Each document type has a rule (preset or custom): characters, length, mask, pattern and checksum. Presets include:

| Preset | Format | Check |
|---|---|---|
| Aadhaar | 12 digits, not starting 0/1 | Verhoeff checksum |
| PAN | `AAAAA9999A` (4th letter = holder type) | Pattern |
| GSTIN | 15 characters | GSTIN checksum |
| Passport (IN) | `A9999999` | Mask |
| Voter ID (IN) | `AAA9999999` | Mask |

A document number that already verified another account is refused with **409 "This document cannot be used. Please contact support."**

### Shop

The shop owner verifies the **shop** separately (`/tvs-wallet/vendor/kyc`, e.g. GST certificate, business PAN or shop licence). Approval activates the **shop wallet** in that country's currency. Personal KYC and shop KYC are independent.

---

## Wallet PIN (MPIN)

| Rule | Value |
|---|---|
| New PIN | 4 digits; repeated digits and sequences (`0000`, `1234`) are refused |
| When asked | Payments and transfers above the country's `pinAbove` |
| Wrong PIN | "Wrong PIN. N attempt(s) left." |
| Lockout | **5** wrong PINs → locked **15 minutes** |
| Change | Needs the current PIN |
| Forgot PIN | A 6-digit code is emailed (valid **10 min**, **5** tries, at most **3** codes per **15 min**), then code + new PIN |

The PIN is stored only as a bcrypt hash and is never returned by the API. Clients must not log it either: the mobile request logger redacts `pin`, `currentPin`, `otp`, `password*` and `refreshToken`, and the prod flavor writes no logs at all.

---

## Money In

### Card top-up (Stripe)

1. `POST /tvs-wallet/topups { amount, idempotencyKey }` checks the country limits and opens a **Stripe Checkout** session in the wallet currency. Supported: INR, USD, SGD, EUR, GBP, AED, AUD, CAD.
2. The client shows Stripe's page. The mobile app accepts only `https://checkout.stripe.com/` URLs and detects the return URL's `?from=success|cancelled`.
3. Coins are credited **once**, when Stripe confirms the **exact amount and currency**, through any of: the webhook, the status poll (`GET /tvs-wallet/topups/:uuid`), or the sweep.
4. Cancelling (`POST /tvs-wallet/topups/:uuid/cancel`) expires the Stripe session.

Safety nets:
- **Lost webhook:** the sweep settles pending top-ups older than 2 minutes.
- **Wallet frozen while paying:** the card is **refunded** instead of crediting.
- **Amount or currency mismatch:** nothing is credited.

### Admin adjustment

A **two-admin** flow: one admin requests a credit or debit (own coins or bonus, with a reason and optional bonus expiry), and a **different** admin approves or rejects. Self-approval is refused.

### Rewards and refunds

Rewards arrive from offers (see [Offers & Rewards](#offers--rewards)). Refunds return to the bucket the coins came from: bonus first, then own coins.

---

## Money Out

### Scan & Pay (shop QR)

```
scan QR (shop token) ─► POST /qr/resolve ─► POST /qr/quote ─► POST /qr/pay
                         shop, currency,     discount, bonus/   idempotencyKey,
                         canPay + reason     own split, payable expectedPayable, pin
```

- The QR carries the shop's token (member QRs start with `tvs:u:` and open Send instead).
- **Resolve** says whether the payer can pay: wallet inactive, frozen, or **own shop**. It also says whether the shop accepts coins (verified, not frozen).
- **Quote** applies the best automatic offer, or a typed coupon code, and shows `"30.00 from bonus · 70.00 from your coins"`.
- **Pay** sends `expectedPayable`. If an offer changed since the quote, it fails with **`QUOTE_CHANGED`** and the client re-quotes. Nothing is charged.
- Above `pinAbove` the MPIN is required. Above `qrPerTxnMax` the payment is refused.
- Paying a shop in **another currency** converts through the `FX` system wallets, balanced in each currency.
- **Refunds:** the shop (`/tvs-wallet/vendor/payments/:uuid/refund`) or an admin can refund in parts, never more than was paid. Coins go back to the bonus and own-coin buckets they were paid from.

### Send coins (member to member)

- Both members must be **verified**. Sending to yourself is refused.
- Only **own coins** can be sent; bonus stays with the sender ("You can send up to ₹X").
- The transfer limits and `pinAbove` apply.
- `POST /tvs-wallet/transfers/resolve` shows the masked name ("Bob M.") and whether they can receive.

### Marketplace checkout

- The store prices in **USD**; TVS converts to the wallet currency (e.g. $109 → ₹9,047 at 83).
- `POST /tvs-wallet/checkout/quote` returns `canPay`, the coins needed, the shortfall (`INSUFFICIENT_FUNDS`, "You need N more TVS Coins") and the applicable offers.
- `POST /tvs-wallet/checkout/pay { addressId, idempotencyKey, expectedCoins, pin }` pays the order. The order is `PAID` immediately.
- **Cancelling** a TVS-paid order queues an `ORDER_REFUND`, posted by the order-refunds job. The order becomes `REFUNDED`.

### Auction wins

`POST /tvs-wallet/auction/:allotmentUuid/quote` and `/pay` pay a won allotment with coins, converted like checkout.

---

## Exchange Rates (FX)

- **Live rates** come from ExchangeRate-API (`EXCHANGE_RATE_API_KEY`), refreshed every 30 minutes and cached in Redis.
- If the live rate is missing, the country's **`storeRate`** is used, provided it is fresh.
- Any rate older than **36 hours** is refused (`RATE_UNAVAILABLE`). A payment is never priced on a guess.
- Admins see the current rates and can refresh them (`GET /admin/tvs-wallet/fx`, `POST …/fx/refresh`).

---

## Offers & Rewards

An offer is **WHO** (audience, visibility) + **WHEN** (trigger, dates, hours) + **IF** (conditions, unlock) + **WHAT** (benefit, delivery) + **LIMITS** + **PAID BY**. Every offer belongs to exactly one country.

| Dimension | Values |
|---|---|
| Kind | `DISCOUNT` (reduces what is paid), `REWARD` (coins credited) |
| Family | `CHECKOUT_DISCOUNT`, `CASHBACK`, `MILESTONE`, `TOPUP`, `SOURCE_BONUS`, `REFERRAL`, `ADMIN_GRANT` |
| Mode | `AUTO` (applies itself), `CODE` (typed coupon), `ASSIGNED` (given to chosen users), `EVENT` (fires on a trigger) |
| Trigger | `CHECKOUT`, `QR_PAYMENT`, `PAYMENT` (either), `TOPUP`, `KYC_APPROVED`, `SOURCE_ATTACHED`, `SIGNUP`, `REFERRAL`, `MANUAL` |
| Benefit | `PERCENT` (with cap), `FIXED`, `COINS`, `PERCENT_COINS`, `FREE_SHIPPING`, `TIERED` (spend more, save more) |
| Delivery | `INSTANT`, `AFTER_DAYS`, `AFTER_RETURN_WINDOW`; into `BONUS` (expires) or `AVAILABLE` |
| Status | `DRAFT` → `SCHEDULED` / `ACTIVE` ⇄ `PAUSED` → `ENDED` → `ARCHIVED` |

**Who sees it.** Country, states, cities, PIN codes, and map circles (lat/lng + radius) matched against the customer's **verified home address**, plus exclusions (`excludeCities`, …). The audience can be new users within N days, first-time payers, win-back (inactive N days), specific users, or users who joined through given sources or source types.

**Conditions & limits.** Minimum amount, shops, brands, categories, payment methods, days of week and hours, nth or every nth payment, first top-up only. Limits: total budget, total uses, per user, per user per day, cycles per user, and the referrer's monthly cap.

**Best offer wins.** At quote time the engine picks the best eligible offer. A typed code applies only when it beats the automatic offer. Single-use and max-use **codes** (with expiry) are generated per offer.

**Paid by.** A discount's cost is split between `platform`, `vendor` and `brand` (a brand partner source), posted as `OFFER_DISCOUNT_SUBSIDY`.

**On refund**, unspent cashback is **clawed back** (`REWARD_CLAWBACK`) and discounts are returned proportionally.

Admins can **simulate** an offer for a user and amount, see **redemptions** and cancel them, and **assign** coupons or goodwill coins to users by email.

---

## Referrals, Partners & Commissions

- **Invite a friend.** Every member has an invite code, link and QR. A new member can add one code **once, within 14 days of joining**; their own code and unknown codes are refused. The `REFERRAL` offer pays the friend and the inviter, typically after the friend's KYC, within the inviter's monthly cap.
- **Partner sources.** Admins create sources of type `BRAND`, `INFLUENCER`, `CAMPAIGN` or `SHOP`, each with one or more codes. Users who join with a source's code are attributed to it, which drives `SOURCE_ATTACHED` joining bonuses (e.g. "100 coins for AI+ Nova buyers, brand pays, after KYC"). A source with an `ownerUserId` shows its stats on that user's **Partner** page.
- **Commissions.** Influencer, campaign and shop sources can earn per signup, per KYC approval, on the first payment, and a percentage of payments (with a cap, within N days of joining). Brands earn no commission; they fund offers instead. Admins approve or cancel commissions in bulk.

---

## Admin Console

**Web → Admin → TVS Wallet** (`TvsAdminPage`): Overview, Wallets, Adjustments, KYC, Offers (editor + detail), Sources (partners), Commissions, Countries, Reports.

| Permission | Allows |
|---|---|
| `tvs_wallet.view` | Read everything |
| `tvs_wallet.adjust` | Request adjustments, refund QR payments |
| `tvs_wallet.approve` | Approve or reject adjustments (must be a different admin) |
| `tvs_wallet.freeze` | Freeze / unfreeze wallets, revoke KYC (with `kyc.review`) |
| `tvs_wallet.kyc.review` | Review KYC, view documents |
| `tvs_wallet.settings` | Countries, FX refresh, wallet backfill |
| `tvs_wallet.offers` | Offers, codes, sources, commissions |

Customers calling `/admin/tvs-wallet/*` get **403**.

---

## Background Jobs

BullMQ queue `tvs-wallet`:

| Job | Every | Does |
|---|---|---|
| `expire-bonus` | 15 min | Expires bonus lots past their date (once each), posts `BONUS_EXPIRY` |
| `sweep-topups` | 2 min | Settles or closes top-ups pending > 2 min (lost webhooks, expired sessions) |
| `order-refunds` | 2 min | Refunds coins for cancelled TVS-paid orders |
| `offers-due` | 5 min | Delivers delayed rewards (after N days / return window) and catches up offer events that were missed |
| `bonus-reminders` | 60 min | Reminds members of bonus about to expire |
| `backfill-wallets` | on demand | Creates missing wallets (Admin → Wallets → backfill) |

---

## API Reference

All paths are under `/api/v1`. Responses are wrapped as `{ success, statusCode, message, data: { message, data } }`. Amounts travel as strings with 2 decimals (`"50.00"`).

### Customer

| Method & path | Purpose |
|---|---|
| `GET /tvs-wallet` | Wallets, balances, KYC status |
| `GET /tvs-wallet/statement?walletUuid&cursor&limit&type` | Activity, cursor-paged (`nextCursor`) |
| `GET /tvs-wallet/bonus` | Bonus lots with expiry |
| `GET /tvs-wallet/kyc/requirements` · `GET /tvs-wallet/kyc` · `POST /tvs-wallet/kyc` | KYC |
| `GET /tvs-wallet/pin` · `POST /tvs-wallet/pin` | PIN status / set or change (`pin`, `currentPin`) |
| `POST /tvs-wallet/pin/reset/request` · `POST …/reset/confirm` | Forgot PIN (`otp`, `pin`) |
| `POST /tvs-wallet/topups` · `GET …/:uuid` · `POST …/:uuid/cancel` | Card top-up |
| `POST /tvs-wallet/transfers/resolve` · `POST /tvs-wallet/transfers` | Send coins |
| `POST /tvs-wallet/qr/resolve` · `/qr/quote` · `/qr/pay` | Scan & Pay |
| `POST /tvs-wallet/checkout/quote` · `/checkout/pay` | Pay a cart / buy-now / booking |
| `POST /tvs-wallet/auction/:allotmentUuid/quote` · `/pay` | Pay an auction win |
| `GET /tvs-wallet/offers` · `GET /tvs-wallet/offers/history` | My offers, rewards history |
| `GET /tvs-wallet/referrals` · `POST /tvs-wallet/referrals/apply` | Invite code, stats, add a code |
| `GET /tvs-wallet/invite/:code` *(public)* | Describe an invite code |
| `GET /tvs-wallet/partner/sources` · `…/:uuid` | Partner dashboard |

### Shop

| Method & path | Purpose |
|---|---|
| `GET /tvs-wallet/vendor` | Shop wallet |
| `GET /tvs-wallet/vendor/kyc/requirements` · `GET`/`POST /tvs-wallet/vendor/kyc` | Shop verification |
| `GET /tvs-wallet/vendor/payments` · `POST …/:uuid/refund` | QR payments received, refunds |

### Admin (`/admin/tvs-wallet`)

`wallets` (list, detail, statement, freeze, unfreeze, backfill) · `adjustments` (list, request, approve, reject) · `kyc` (list, detail, files, approve, reject, revoke user / shop) · `payments/:uuid/refund` · `fx` · `countries` · `lookups` · `offers` (CRUD, status, duplicate, simulate, assign, redemptions, codes) · `redemptions/:uuid/cancel` · `codes/:code/status` · `sources` (CRUD, status, codes) · `source-codes/:code/status` · `commissions` (list, status) · `reports/{overview,offers,brands,partners}`.

Swagger: `/docs` on the API server.

---

## Error Codes

| Code | Meaning |
|---|---|
| `KYC_REQUIRED` / `WALLET_INACTIVE` | Verify identity first |
| `WALLET_FROZEN` | Wallet on hold |
| `INSUFFICIENT_FUNDS` | Not enough coins (bonus can't cover transfers) |
| `PAYEE_NOT_ACCEPTING` | Shop not verified or frozen |
| `SELF_PAYMENT` | Paying your own shop / sending to yourself |
| `LIMIT_EXCEEDED` | A country limit was hit |
| `RECIPIENT_NOT_ELIGIBLE` | Recipient not verified |
| `PIN_NOT_SET` / `PIN_REQUIRED` / `PIN_INVALID` / `PIN_LOCKED` | MPIN problems |
| `OTP_INVALID` | Wrong or expired reset code |
| `QUOTE_CHANGED` | Price changed since the quote — re-quote |
| `RATE_UNAVAILABLE` | No fresh exchange rate |
| `CURRENCY_NOT_SUPPORTED` | Currency can't be topped up |
| `TOPUP_UNAVAILABLE` | Card top-ups not configured |
| `REFUND_EXCEEDS_PAYMENT` | Refund larger than what's left |
| `CODE_INVALID` / `OFFER_NOT_APPLICABLE` | Coupon / invite code problems |
| `IDEMPOTENCY_CONFLICT` | That request id is still being processed, or it was sent before and didn't complete — check its status or use a new id |
| `TOO_MANY_REQUESTS` | Rate limited |
| `STAFF_ACCOUNT` | Staff accounts have no wallet |

---

## Client Screens

### Mobile (Flutter)

| Route | Screen | Code |
|---|---|---|
| `/tvs-wallet` | Wallet: balance card, Add money / Send / Receive / MPIN, tabs Activity · Bonus · Offers · Invite | `features/tvs_wallet/presentation/screens/tvs_wallet_screen.dart` |
| `/tvs-wallet/topup` | Add money (Stripe in-app) | `tvs_topup_screen.dart` |
| `/tvs-wallet/send` | Send coins | `tvs_send_screen.dart` |
| `/tvs-wallet/verify` | KYC | `features/scanner/.../wallet_kyc_screen.dart` |
| `/tvs-wallet/mpin`, `/tvs-wallet/mpin/reset` | Set / change / reset MPIN, PIN entry for payments | `wallet_mpin_screen.dart` |
| `/scanner` → `/review-Payment` → `/transferSuccess` | Scan & Pay (camera or gallery QR) → review & pay → receipt | `scanner_screen.dart`, `scanner_review_pay_screen.dart`, `transaction_success_screen.dart` |
| `/payment` → `/payment/review` → `/payment/card` | Checkout; TVS Wallet is one method beside Bingold, Card, Crypto, Cash on delivery | `features/payment/...` |

The Profile screen shows a TVS Wallet card and the **Wallet Security** entries (Set / Change MPIN, Reset MPIN).

### Web (React)

Customer: `TvsWalletPage` (with `TopupModal`, `SendCoinsModal`, `PinSettingsModal`, `OffersPanel`, `InvitePanel`, `HomeAddressCard`), `KycPage`, `TopupReturnPage`, `JoinPage` (invite link), `PartnerPage`; vendor `ShopWalletPage`; the checkout option `components/tvs-wallet/TvsCheckoutOption`.
Admin: `pages/admin/tvs-wallet/*` (see [Admin Console](#admin-console)).

---

## Testing

- **End-to-end cases (mobile):** `tvs_wallet_payments_test_cases.csv` at the repo root. 80 cases covering the wallet, KYC, MPIN, top-up, send, Scan & Pay, offers, invite and all checkout methods, with the result of each run.
  - Last run 19 Oct 2026 on the iOS Simulator against an isolated local backend: 76 pass, 3 partial (camera-only steps; offer not shown on the top-up screen; method not shown on the order receipt), 1 blocked (live camera scanning).
- **Backend:** unit specs beside each rule file (`*.rules.spec.ts`), and `tvs-wallet.integration.spec.ts`, which runs against a **throwaway** MySQL when `TVS_WALLET_TEST_DATABASE_URL` is set. It covers activation, parallel payments, idempotency, FX, bonus expiry, refunds, offers, referrals, and the ledger staying balanced.
- **QA data:** `npm run db:seed:tvs-wallet:qa` (backend, local/QA only) creates countries, partners and an offer for every type through the admin API; `…:qa:remove` deletes them.
