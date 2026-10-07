# EverQpid — Testing (Phase 11)

**Date:** 2026-07-21  
**Scope:** Automated tests + CI. No app architecture / UI / provider / networking redesign.

---

## How to run

```bash
# Unit + widget (default CI suite)
flutter test test/unit test/widgets test/upload_validation_check.dart test/widget_test.dart

# With coverage (writes coverage/lcov.info)
flutter test test/unit test/widgets test/upload_validation_check.dart test/widget_test.dart --coverage

# Goldens
flutter test --update-goldens test/golden
flutter test test/golden

# Integration (mocked API journeys; needs flutter-tester / device)
flutter test integration_test/app_flow_test.dart -d flutter-tester
```

Optional HTML coverage:

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Layout

```
test/
  helpers/          Dio harness, FakeApiService, Fake Firebase, fixtures, pump helpers
  unit/
    repositories/   Auth/email, profile, home, matching, chat, subscription, clan, verification
    viewmodels/     Matching, GetProfile, Verification (+ subscription via repository)
    network/        NetworkApiServiceV2 mock + helpers
  widgets/          Login, MessageBubble, Settings, OTP/Home/Discovery/Matches/Profile shells
  golden/           Buttons, cards, dialog, chat bubble, subscription, clan
  upload_validation_check.dart
integration_test/
  app_flow_test.dart
.github/workflows/flutter_ci.yml
```

---

## Strategy

| Layer | Approach |
|-------|----------|
| Repositories | Real repos + `http_mock_adapter` on `NetworkApiServiceV2.instance.adapter` |
| ViewModels | Same Dio mock; assert loading / success / failure / notifyListeners |
| Widgets | Smoke on real screens where light; shells for heavy trees |
| Goldens | Shell widgets (no Google Fonts network); update with `--update-goldens` |
| Integration | Mocked API journey: OTP → discover → like/match → chat → sub → logout → delete |

Helpers:

- `DioTestHarness` — fake Dio  
- `FakeApiService` — `BaseApiService` fake for future DI  
- `FakeFirebaseAuthSession` — Firebase stand-in without init  

---

## Coverage (measured 2026-07-21)

From `flutter test … --coverage` → `coverage/lcov.info`:

| Area | Target | Actual (folder-wide) | Notes |
|------|--------|----------------------|-------|
| Repositories | 90% | ~14% | Happy-path + error on critical methods; many unused sibling methods/files |
| ViewModels | 85% | ~2% | Matching / GetProfile / Verification exercised; Chat/Auth/Subscription VMs need Firebase/socket/Razorpay fakes |
| Feature views | 60% | ~7% | PhoneLogin, MessageBubble, Settings smoke; full trees need Provider graphs |
| All `lib/` in lcov | — | ~9% | Baseline for CI artifact |

**Critical-path confidence** (methods under test for auth/profile/home/matching/chat/subscription/clan/verification) is high; folder-wide % is low because lcov includes every line in every repository/VM file.

CI uploads `coverage/lcov.info` on every PR. Coverage gates (fail below target) are **not** enforced yet.

---

## CI integration

Workflow: `.github/workflows/flutter_ci.yml`

1. `flutter pub get`  
2. `flutter analyze --no-fatal-infos`  
3. `flutter test --coverage`  
4. Upload `coverage/lcov.info`  

Goldens / integration stay optional in CI until OS-locked baselines and a device job exist. Run locally:

```bash
flutter test test/golden
flutter test integration_test/app_flow_test.dart -d flutter-tester
```

---

## Remaining gaps

- Full OTP / Firebase Auth repository tests (`firebase_auth_mocks` or injected Auth).  
- Chat socket ViewModel + message send (socket not mocked).  
- SubscriptionViewModel (Razorpay platform channels) — repository covered instead.  
- Home/Discovery/Matches/Profile full widget trees (heavy providers).  
- S3 PUT via private `_s3Adapter` when URL contains `amazonaws.com` / `s3.` — tests use non-S3 signed URLs.  
- Device lab for true E2E signup → delete account against staging.  
- Raise folder-wide coverage toward targets; add CI coverage gates when baseline is stable.  
- Golden PNGs are platform-sensitive — regenerate on the OS you lock in CI.  
- `LogoutViewModel` / `LoggedInUser.clearUserData` need Firebase + secure_storage plugins — integration covers in-memory wipe only.  
- Debug APK may fail on Kotlin metadata mismatch (Firebase Auth vs project Kotlin) — unrelated to tests; use `flutter test` / web build for compile smoke.
