# EverQpid — Security (Phase 9)

**Date:** 2026-07-21  
**Scope:** Token storage, logging hygiene, HTTPS enforcement, upload validation, web headers, Firebase checklist. No UI / business-logic redesign.

---

## Threat model (app-facing)

| Threat | Mitigation (current) | Residual |
|--------|----------------------|----------|
| Stolen device / backup reads JWT from prefs | Mobile JWTs in `flutter_secure_storage` (Keystore / Keychain) | Rooted/jailbroken devices can still extract secrets |
| XSS / malicious script reads JWT on web | JWTs **not** written to `localStorage` / SharedPreferences on web | In-memory Bearer still XSS-reachable while tab is open |
| Token leakage via logs | Scrubbed network logger; removed OTP / FCM / response dumps | Debug `log()` elsewhere may still print PII (emails, phones) |
| MITM / cleartext API | Staging + production refuse non-`https://` API/socket/image bases | Development allows LAN `http://` |
| Malicious upload | Client size + magic-byte MIME + filename sanitize | Backend must enforce; signed-URL TTL is server-owned |
| Refresh storm / loops | Single-flight `refreshAccessToken()` Completer | Multi-tab web each has own memory tokens until cookies |
| Session after logout | Clears prefs + secure tokens + Firebase sign-out | Server must invalidate refresh token (logout API) |

---

## Token flow

```
Login / OTP / email auth
        │
        ▼
LoggedInUser.accessToken + refreshToken (memory)
        │
        ├── Mobile: FlutterSecureStorage write
        └── Web: memory only (no persistence)
        │
        ▼
Dio onRequest → Authorization: Bearer <access>
        │
        ▼
401 → refreshAccessToken() once (single-flight)
        │
        ├── success → tokenUpdate → persist → retry
        └── fail → clearUserData → login screen
```

Logout: backend `log-out` with refresh token (best-effort) → Firebase `signOut` → `LoggedInUser.clearUserData()` (secure delete + `SharedPreferences.clear()`).

### Storage strategy

| Platform | Access / refresh JWT | Profile fields |
|----------|----------------------|----------------|
| Android / iOS | `flutter_secure_storage` | SharedPreferences |
| Web | **In-memory only** for the browser session | SharedPreferences → browser storage (non-secret) |

**Temporary (web):** Backend still issues Bearer JWTs consumed by Dio. Preferred end state: **httpOnly; Secure; SameSite** cookies set by the API on `web.everqpid.com` / API domain, with CSRF strategy, and client stops attaching `Authorization` from JS.

Legacy SharedPreferences JWT keys are migrated to secure storage once on mobile, then removed.

---

## Logging rules

Never log:

- `Authorization` / Bearer values  
- Refresh or access tokens  
- OTP / passwords  
- Razorpay signature / payment ids  
- FCM device tokens  
- Full auth API response bodies (may embed tokens)

`NetworkLogger` redacts sensitive headers/body keys and is silent for normal traffic in release.

---

## HTTPS only (deployed envs)

`NetworkApiServiceV2` throws at init if `ENV` is `staging` or `production` and any of `apiUrl` / `socketUrl` / `imageBaseUrl` is not `https://`.

| Env | Default hosts | Cleartext |
|-----|---------------|-----------|
| production / staging | `https://server.everqpid.com` | Blocked |
| development | LAN `http://15.206.227.36:8000` | Allowed for local API only |

Never ship a production binary with `ENV=development` or `--dart-define=API_URL=http://...`.

---

## Upload validation

Client helper: `lib/Settings/helper/upload_validation.dart`

- Max image **8 MB**, audio **15 MB**  
- MIME from magic bytes (JPEG/PNG/GIF/WebP)  
- Filename sanitization (no path traversal)  
- Wired into profile photo upload, chat media, selfie verification  

**Backend must:** short signed-URL expiry, server-side MIME/size checks, virus/content scanning as needed. Client cannot see expiry TTL in code today — confirm on API.

---

## Firebase checklist (console)

Project: `everqpid-2601a` (see `firebase.json` / `lib/firebase_options.dart`).

| Area | Action |
|------|--------|
| API keys | Restrict Android/iOS/Web keys by app package / bundle / HTTP referrer |
| Auth domains | Authorize only `web.everqpid.com` (+ localhost for local web) |
| Phone Auth | Production reCAPTCHA / Play Integrity as required |
| Storage / Firestore | This app primarily uses custom API + S3 signed URLs; if Firebase Storage/Firestore enabled, lock rules to authenticated owners only |
| FCM | Restrict sender; keep `firebase-messaging-sw.js` aligned with web config; never log tokens |
| App Check | Recommended for production abuse resistance |

---

## Web security headers (Nginx / aaPanel)

Add on the **Flutter Web** site (and prefer HSTS only after HTTPS is verified):

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "camera=(self), microphone=(self), geolocation=(self)" always;
add_header Cross-Origin-Opener-Policy "same-origin-allow-popups" always;
# COEP can break Google Sign-In / Firebase / third-party embeds — enable only after testing:
# add_header Cross-Origin-Embedder-Policy "require-corp" always;

# CSP — start report-only, then enforce. Adjust for Firebase, Google Sign-In, S3, API, sockets.
add_header Content-Security-Policy "
  default-src 'self';
  script-src 'self' 'unsafe-inline' 'wasm-unsafe-eval' https://www.gstatic.com https://www.googleapis.com https://apis.google.com;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  font-src 'self' https://fonts.gstatic.com data:;
  img-src 'self' data: blob: https:;
  connect-src 'self' https://server.everqpid.com wss://server.everqpid.com https://*.googleapis.com https://*.firebaseio.com https://*.google.com https://*.gstatic.com;
  frame-src 'self' https://accounts.google.com https://*.firebaseapp.com;
  worker-src 'self' blob:;
  object-src 'none';
  base-uri 'self';
  form-action 'self';
" always;
```

Also keep Phase 8 cache rules: **no-cache** `index.html` + service worker; immutable hashed assets. See `docs/WEB_DEPLOYMENT.md`.

---

## Deployment checklist

- [ ] Build with `ENV=production` (default) and HTTPS dart-defines if overriding  
- [ ] Confirm Google OAuth authorized origins / redirect URIs for production web host  
- [ ] Rotate any keys that ever appeared in logs or git history  
- [ ] Apply Nginx security headers above  
- [ ] Verify logout clears session (mobile: reinstall not required; web: new tab after logout has no Bearer)  
- [ ] Confirm refresh does not loop (forced 401 once → login)  
- [ ] Firebase API key restrictions + Auth domains  
- [ ] Backend: refresh token rotation + revoke on logout; signed-URL TTL  

---

## Known limitations

1. **Web Bearer JWTs** — temporary until httpOnly cookies.  
2. **Web session** — refresh of the page after login logs the user out (tokens not persisted).  
3. **Development HTTP** — intentional for LAN API.  
4. **CSP** — Flutter Web often needs `'unsafe-inline'` / wasm eval; tighten over time.  
5. **COEP** — may break Google Sign-In; left optional.  
6. **Razorpay / contacts / recording** — platform plugins; follow vendor threat models.  
7. **No Firestore/Storage rules in repo** — configure in Firebase console if those products are used.  

---

## Compile / self-check

```bash
flutter analyze lib/Data/LocalStorage lib/Data/Network lib/Settings/helper/upload_validation.dart
flutter test test/upload_validation_check.dart
flutter build apk --release   # or ios / web as needed
```
