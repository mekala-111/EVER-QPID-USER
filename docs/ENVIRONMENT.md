# EverQpid — Environment Configuration (Phase 3)

**Date:** 2026-07-21  
**Scope:** Configuration only. Auth, UI, repositories, and providers unchanged.

---

## Architecture

```
--dart-define=ENV / API_URL / …
        │
        ▼
lib/config/config.dart          ← AppConfig (String.fromEnvironment + fallbacks)
        │
        ├── environment.dart    ← AppEnvironment { development, staging, production }
        ├── development.dart    ← DevelopmentConfig defaults
        ├── staging.dart        ← StagingConfig defaults
        └── production.dart     ← ProductionConfig defaults
        │
        ▼
lib/Settings/constants/app_url.dart
        └── AppUrl.baseurl / socketUrl / isProduction  →  delegates to AppConfig
        └── route path constants unchanged (repositories keep importing AppUrl)
```

**Resolution order for each value**

1. `--dart-define=KEY=value` if non-empty  
2. Else the default for the selected `ENV`  
3. Else (production defaults when `ENV` is missing)

---

## Environment variables

| Define | AppConfig getter | Purpose |
|--------|------------------|---------|
| `ENV` | `environment` | `development` \| `staging` \| `production` (aliases: `dev`, `stage`, `prod`) |
| `API_URL` | `apiUrl` | Dio / HTTP API base URL |
| `SOCKET_URL` | `socketUrl` | Socket.IO host (falls back to `apiUrl`) |
| `IMAGE_BASE_URL` / `IMAGE_URL` | `imageBaseUrl` | Image CDN / media base |
| `GOOGLE_MAP_KEY` | `googleMapKey` | Google Maps |
| `RAZORPAY_KEY` | `razorpayKey` | Fallback Razorpay key (order API key still preferred) |
| `GOOGLE_WEB_CLIENT_ID` | `googleWebClientId` | Google Sign-In server / web client ID |
| `FACEBOOK_APP_ID` | `facebookAppId` | Facebook app id (native config may still be required) |
| `PRIVACY_POLICY_URL` | `privacyPolicyUrl` | Privacy WebView |
| `TERMS_URL` | `termsUrl` | Terms WebView |
| `CONTACT_EMAIL` | `contactEmail` | Support contact |
| `DEFAULT_COUNTRY` | `defaultCountry` | ISO country default (e.g. `IN`) |
| `APP_NAME` | `appName` | App display name |
| `PLACEHOLDER_IMAGE_URL` | `placeholderImageUrl` | Avatar fallback image |

### Default hosts (when defines omitted)

| ENV | API / Socket default |
|-----|----------------------|
| `development` | `http://15.206.227.36:8000` |
| `staging` | `https://server.everqpid.com` |
| `production` (default) | `https://server.everqpid.com` |

---

## Build examples

### Run (development)

```bash
flutter run \
  --dart-define=ENV=development \
  --dart-define=API_URL=http://15.206.227.36:8000 \
  --dart-define=SOCKET_URL=http://15.206.227.36:8000
```

### APK (production)

```bash
flutter build apk \
  --release \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://server.everqpid.com \
  --dart-define=SOCKET_URL=https://server.everqpid.com
```

### App Bundle

```bash
flutter build appbundle \
  --release \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://server.everqpid.com
```

### Web (production)

```bash
flutter build web \
  --release \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://server.everqpid.com \
  --dart-define=SOCKET_URL=https://server.everqpid.com \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

### Staging

```bash
flutter run \
  --dart-define=ENV=staging \
  --dart-define=API_URL=https://server.everqpid.com
```

---

## Deployment notes

- **CI/CD:** pass secrets only via `--dart-define` or `--dart-define-from-file` (Flutter 3.7+). Never commit live keys into `development.dart` / `staging.dart` / `production.dart` beyond public client IDs.
- **Web Google Sign-In:** `web/index.html` meta `google-signin-client_id` cannot read dart-define. Keep it in sync with `GOOGLE_WEB_CLIENT_ID` when rotating OAuth clients.
- **Firebase:** `lib/firebase_options.dart` remains FlutterFire-generated per platform. Rotate / restrict API keys in Google Cloud; do not treat those client keys as server secrets.
- **Razorpay:** checkout prefers `key_id` from the create-order API response; `RAZORPAY_KEY` is a fallback only.
- **Facebook:** `FACEBOOK_APP_ID` is exposed for Dart; native Android/iOS Facebook SDK config still lives in platform project files.

---

## Migration notes

| Before | After |
|--------|-------|
| `AppUrl.isProduction` hardcoded `true` + IP branches | `AppConfig.environment` via `ENV` |
| Hardcoded `https://server.everqpid.com` / `http://15.206…` in `AppUrl` | `AppConfig.apiUrl` / env defaults |
| Socket used `AppUrl.baseurl` | `AppUrl.socketUrl` → `AppConfig.socketUrl` |
| Privacy / terms URLs in screens | `AppConfig.privacyPolicyUrl` / `termsUrl` |
| Google web client ID in `AuthRepository` | `AppConfig.googleWebClientId` |
| Empty `lib/env.dart` (`Environments`) | **Deleted** — replaced by `lib/config/` |
| `AppUrl` route constants | Unchanged — repositories keep working |

**Compatibility:** Existing `AppUrl.getMyMatches`, `AppUrl.refreshToken`, etc. still work. Prefer `AppConfig` for new host/secret reads.

---

## Remaining non-config hardcodes (intentional)

| Location | Why left |
|----------|----------|
| `lib/firebase_options.dart` | FlutterFire platform configs (Phase 11 / Firebase tooling) |
| `web/index.html` Google meta tag | HTML cannot consume dart-define |
| Android/iOS Facebook / Google native XML/plist | Platform SDK requirements |
| Error string mentioning `http://127.0.0.1` in auth | Developer guidance only, not a host config |
| S3 signed URLs from API | Runtime from backend, not app config |
| Commented code in dead `network_api_service.dart` | Cleanup Phase 5 |
