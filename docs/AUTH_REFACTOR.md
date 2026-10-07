# EverQpid — Authentication Refactor (Phase 2)

**Date:** 2026-07-21
**Scope:** Authentication only. No UI changes, no repository interface changes, no provider/env changes.

---

## Previous flow (broken)

```
Login → store accessToken + refreshToken
      → every API request:   Authorization: Bearer <REFRESH token>   ← wrong
      → socket privateMessage: token = <REFRESH token>               ← wrong
      → 401 → two overlapping refresh handlers (onResponse body-401 and
              onError HTTP-401 with two duplicated retry blocks)
      → retry with Bearer <REFRESH token>                            ← wrong
      → refresh success → hardcoded 1.4 s sleep
```

Problems:

- The long-lived refresh token was exposed on **every** request and socket message. If any request/log leaked, an attacker held a long-lived credential.
- `accessToken` was stored and persisted but never used for API auth.
- Refresh logic was duplicated three ways (`onResponse` → `_handleTokenRefresh`, plus two blocks inside `onError`), each with its own Completer handling and retry clone.
- The Completer guard was per-instance, but every repository creates its own `NetworkApiServiceV2()` — parallel 401s across repositories could still fire parallel refresh calls.
- Retry had no loop guard: a 401 after refresh could re-enter refresh indefinitely.
- Tokens, FCM tokens, Razorpay payment IDs/signatures, and full response bodies (which contain tokens on login) were written to logs.

## New flow

```
Login → store accessToken + refreshToken (unchanged)

API request
  └─ Authorization: Bearer accessToken        (interceptor, all requests)
     refresh endpoint gets NO Authorization header

401 (HTTP status or body statusCode)
  └─ refreshAccessToken()   — single implementation, single-flight
       ├─ already refreshing?  → await the same in-flight Future (queue)
       ├─ POST /api/v1/auth/refresh-tokens  { refreshToken } (body only)
       ├─ success → LoggedInUser.tokenUpdate() → persists accessToken
       │            (refreshToken only overwritten if API returned a new one)
       └─ failure → logout: clear storage → navigate splash/login
  └─ retry original request with Bearer accessToken (marked `retried`)
       └─ second 401 on a retried request → logout (no infinite loop)
```

### Refresh sequence diagram

```mermaid
sequenceDiagram
    participant App
    participant Dio as Dio interceptor
    participant API as API server

    App->>Dio: request
    Dio->>API: GET /x  (Bearer accessToken)
    API-->>Dio: 401
    Dio->>Dio: refreshAccessToken()  (single-flight; others await)
    Dio->>API: POST /auth/refresh-tokens  {refreshToken in body}
    API-->>Dio: 200 {tokens}
    Dio->>Dio: LoggedInUser.tokenUpdate → persist
    Dio->>API: retry GET /x  (Bearer NEW accessToken, extra.retried=true)
    API-->>Dio: 200
    Dio-->>App: response
    Note over Dio,API: refresh fails OR retried request 401s again →<br/>clearUserData() + navigate to splash
```

---

## Files changed

| File | Change |
|------|--------|
| `lib/Data/Network/network_api_service_v2.dart` | Request interceptor now sends `Bearer accessToken` (skipped for refresh endpoint). Removed both duplicated 401 blocks; single `refreshAccessToken()` (static single-flight Completer shared across all service instances) + single `_retry()` helper with a `retried` flag guard. Removed dead `_pendingRequests`, the 1.4 s post-refresh sleep, and header/body logging (bearer + login tokens were being logged). |
| `lib/Data/LocaStorage/loggedin_user.dart` | `tokenUpdate` no longer overwrites `refreshToken` unless the refresh API returns a new one; fixed un-awaited `prefs.clear()` in `clearUserData` (logout storage clear was fire-and-forget and its failure check never fired). |
| `lib/Features/messages/service/chat_socket_service.dart` | Removed cached `_refreshToken` field; `sendPrivateMessage` now reads `LoggedInUser.accessToken` live per message — after a refresh the next message automatically carries the fresh token, so no reconnect is required (token is per-message, not per-connection; connection itself is unauthenticated as before). |
| `lib/Features/messages/repository/chat_repository.dart` | Removed `token: LoggedInUser.refreshToken` arguments (parameter was ignored by the service anyway); auth now comes solely from the shared interceptor. Dropped unused `LoggedInUser` import. |
| `lib/Features/matches/view/matches_screen.dart` | Removed debug tap handler that logged the access token to console; dropped now-unused imports. |
| `lib/Features/subscription/view_model/subscription_view_model.dart` | Payment success log no longer prints paymentId / orderId / signature. |
| `lib/Data/services/fcm_service.dart` | FCM device token no longer printed in logs (existence-only log). |

## Why changed

- **Correct JWT model:** short-lived access token on the wire; long-lived refresh token confined to the refresh endpoint's request body. Limits blast radius of any leak.
- **One refresh path:** three near-identical handlers collapsed to one — fewer states, one Completer, one retry clone. The Completer is `static` so concurrent 401s from *different* repository instances (each holds its own `NetworkApiServiceV2`) still share one refresh request.
- **No refresh storms / loops:** single-flight queue + retry-once flag.
- **No artificial latency:** the 1.4 s sleep after refresh existed to paper over the refresh-token-as-bearer confusion; with the correct token it is unnecessary.

## Security improvements

1. Refresh token no longer sent as `Authorization` header on any request.
2. Refresh token no longer attached to every socket message.
3. Access/refresh/FCM tokens, payment signatures, request headers, and full response bodies removed from logs.
4. Removed hidden debug gesture that dumped the access token to console.
5. Refresh token is only rotated when the server returns a new one (prevents accidental self-logout on partial refresh responses).
6. Retried requests that still return 401 force logout instead of retrying forever.

## Breaking changes

None intended. Verified:

- Repository interfaces unchanged (`token:` parameter still accepted; it was already ignored by the service).
- Public auth paths (login/OTP/signup) still bypass forced-logout handling (`_isPublicAuthPath` untouched).
- 410/403 handling, 5xx handling, S3 upload path, EasyLoading behavior unchanged.
- **Server expectation check:** the backend must accept `Bearer accessToken` on protected APIs and `accessToken` in the socket `privateMessage.token` field. If the backend was (incorrectly) validating refresh tokens there, it must accept access tokens — this is the standard contract the refresh endpoint implies.

## Remaining auth issues (later phases)

| Issue | Phase |
|-------|-------|
| Tokens in SharedPreferences (plaintext) — move to `flutter_secure_storage` | 11 |
| Every repository still constructs its own `NetworkApiServiceV2` (works, but wasteful) | 4 |
| Data layer imports `main.dart` for `navigatorKey` | 4/5 |
| ~700 verbose `log()` calls remain (non-sensitive) | 12 |
| Proactive refresh before expiry (currently reactive-on-401 only) | optional |

## Compile status

- `flutter analyze`: **0 errors** (198 pre-existing infos/warnings across the repo, none introduced by this phase; the files touched in this phase are clean).
