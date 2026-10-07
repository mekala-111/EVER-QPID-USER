# EverQpid — Monitoring & Observability (Phase 10)

**Date:** 2026-07-21  
**Scope:** Crashlytics, Analytics, centralized logging, light performance metrics. No UI / auth / networking redesign.

---

## Crash flow

```
FlutterError / PlatformDispatcher / runZonedGuarded
        │
        ▼
LoggerService.error(..., fatal: true|false)
        │
        ├── debugPrint (always for errors)
        └── Firebase Crashlytics (Android / iOS only)
              recordFlutterFatalError | recordError
```

| Source | Handling |
|--------|----------|
| Flutter framework errors | `FlutterError.onError` → Crashlytics fatal (mobile) |
| Platform / async engine | `PlatformDispatcher.instance.onError` → Crashlytics fatal |
| Uncaught zone errors | `runZonedGuarded` → `LoggerService.error(..., fatal: true)` |
| Handled failures (network, etc.) | `LoggerService.error` / `warning` → non-fatal |

**Web:** Crashlytics SDK is not used; errors still go through `LoggerService` (console). Prefer browser / hosting logs for web crashes until a web crash product is chosen.

Collection is **disabled in debug** (`setCrashlyticsCollectionEnabled(!kDebugMode)`).

---

## Analytics events

Central API: `AnalyticsService` (`lib/Data/services/analytics_service.dart`).

| Event name | When |
|------------|------|
| `login` | Phone / email login success (`method`) |
| `sign_up` | Phone / email signup success |
| `otp_verified` | Phone / email OTP success |
| `profile_completed` | Signup completes with profile data |
| `match_created` | Like response indicates a match |
| `chat_opened` | `ChatViewModel.initChat` |
| `message_sent` | Text / image / audio send (`type`) |
| `subscription_viewed` | Plans loaded |
| `subscription_purchased` | Razorpay success (`plan_id`) |
| `logout` | Logout cleanup |
| `delete_account` | Account delete success |

Also: `FirebaseAnalyticsObserver` on `MaterialApp` for automatic screen views.

---

## Logging policy

`LoggerService` (`lib/Data/services/logger_service.dart`) — **one API**.

`AppLogger` delegates to it for existing call sites.

| Level | Debug/profile | Release |
|-------|---------------|---------|
| debug / info | console | silent |
| warning | console | Crashlytics non-fatal (mobile) |
| error | console | Crashlytics (fatal flag optional) |

**Never log:** JWT, refresh token, OTP, password, Razorpay signature, FCM token, `Authorization` values.

Messages that look like they contain those substrings are replaced with `[redacted: possible secret in log message]`.

`NetworkLogger` uses `LoggerService` and never prints scrubbed secrets.

---

## Performance metrics

`PerformanceMonitor` (`lib/Data/services/performance_monitor.dart`):

| Metric | Mechanism |
|--------|-----------|
| App startup | `markAppStart` → `recordStartupComplete` → Crashlytics key `startup_ms` |
| Network duration | From `NetworkLogger.response` → slow (≥3s) keys `slow_net_ms` / `slow_net_path` |
| Chat load | `chat_load` stopwatch around history fetch |
| Subscription purchase | `subscription_purchase` stopwatch until Razorpay success |

Slow screens: use Analytics screen views + Crashlytics custom keys when timers exceed thresholds. Deeper Firebase Performance Monitoring (traces) is optional follow-up.

---

## Production dashboards

1. **Firebase Console → Crashlytics** — crash-free users, top issues, custom keys (`startup_ms`, `slow_net_*`, `last_chat_load_ms`, …).
2. **Firebase Console → Analytics** — Events + funnels (login → profile_completed → match_created → subscription_purchased).
3. **Engagement → Screens** — from `FirebaseAnalyticsObserver`.
4. **aaPanel / Nginx access logs** — web 5xx / latency (pair with Phase 8 deploy docs).

---

## Android / iOS notes

- Android: Crashlytics Gradle plugin applied in `android/settings.gradle.kts` + `android/app/build.gradle.kts`.
- iOS: FlutterFire pods via `pod install` after `flutter pub get`.
- Ensure Crashlytics is enabled for the Firebase project `everqpid-2601a`.

---

## Known gaps

- No Firebase Performance Monitoring SDK traces yet.
- Web has no Crashlytics; rely on Analytics + server logs.
- Not every `dart:developer` `log()` call migrated to `LoggerService` (high-volume legacy); secrets were scrubbed in Phase 9 for critical paths; new code should use `LoggerService` / `AppLogger`.
- Match detection depends on backend `isMatch` / `matched` fields in like response.
