# EverQpid — Flutter Web & PWA Deployment

Production target: **Ubuntu + Nginx + aaPanel**, Flutter Web (CanvasKit / default renderer).

> Phase 12 ops guide: **`docs/DEPLOYMENT.md`**, Nginx file **`deploy/nginx/everqpid-web.conf`**, sign-off **`RELEASE_CHECKLIST.md`**.

---

## Build

```bash
# Production (default ENV=production via AppConfig)
flutter clean
flutter pub get
flutter build web --release \
  --base-href=/ \
  --dart-define=ENV=production
```

> Note: `--pwa-strategy` is deprecated in recent Flutter versions. Default release builds still emit `flutter_service_worker.js` with offline-capable asset caching. Use `flutter build web --no-web-resources-cdn` / renderer flags only if needed; see Flutter web docs for current PWA knobs.
Optional defines (see `docs/ENVIRONMENT.md`):

```bash
flutter build web --release \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://server.everqpid.com \
  --dart-define=SOCKET_URL=https://server.everqpid.com \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

Output: `build/web/`

Deploy the **entire** `build/web/` tree to the site root (or subdirectory if `--base-href` matches).

---

## Path URLs (clean URLs)

The app calls `usePathUrlStrategy()` so routes use `/path` instead of `/#/path`.

Nginx **must** fall back to `index.html` for unknown paths (SPA / deep links):

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

Without this: refresh and direct URL navigation return 404.

---

## Nginx recommendations (aaPanel)

Place under the site’s Nginx config (aaPanel → Site → Config).

### SPA + caching

```nginx
# Flutter Web SPA
root /www/wwwroot/web.everqpid.com;   # adjust to your deploy path
index index.html;

location / {
    try_files $uri $uri/ /index.html;
}

# Never cache the shell — always revalidate so SW / entry updates apply
location = /index.html {
    add_header Cache-Control "no-cache, no-store, must-revalidate";
    add_header Pragma "no-cache";
    expires -1;
}

location = /flutter_service_worker.js {
    add_header Cache-Control "no-cache, no-store, must-revalidate";
    add_header Pragma "no-cache";
    expires -1;
}

location = /manifest.json {
    add_header Cache-Control "no-cache";
}

location = /version.json {
    add_header Cache-Control "no-cache, no-store, must-revalidate";
    expires -1;
}

# Hashed Flutter assets — long-lived / immutable
location /assets/ {
    add_header Cache-Control "public, max-age=31536000, immutable";
}

location /canvaskit/ {
    add_header Cache-Control "public, max-age=31536000, immutable";
}

# Main.dart.js / chunk hashes change per build
location ~* \.(js|wasm|css)$ {
    add_header Cache-Control "public, max-age=31536000, immutable";
}

# Icons / favicon — moderate cache
location ~* \.(png|jpg|jpeg|gif|ico|svg|webp)$ {
    add_header Cache-Control "public, max-age=604800";
}
```

### Compression

Enable gzip (and brotli if aaPanel/Nginx module is available):

```nginx
gzip on;
gzip_comp_level 5;
gzip_min_length 256;
gzip_proxied any;
gzip_types
    text/plain
    text/css
    text/javascript
    application/javascript
    application/json
    application/wasm
    image/svg+xml
    application/manifest+json;

# If ngx_brotli is installed:
# brotli on;
# brotli_types text/plain text/css application/javascript application/json application/wasm;
```

### HTTPS / HTTP2

Terminate TLS in aaPanel (Let’s Encrypt). Prefer HTTP/2 for Flutter’s many asset requests.

### API / Socket CORS

Browser origin `https://web.everqpid.com` must be allowed by `https://server.everqpid.com` (API + Socket.IO). That is a **backend** concern, not Nginx static hosting.

---

## PWA behavior

| Item | Behavior |
|------|----------|
| Manifest | `web/manifest.json` → copied to build (`name` EverQpid, theme `#9B5DE5`, maskable icons) |
| Service worker | Generated as `flutter_service_worker.js` on `flutter build web` |
| Strategy | Default release SW caches app shell + hashed assets (offline-first style) |
| Updates | New build → new SW version. Users get update after SW activates (may need a second visit). Keep `index.html` + SW **no-cache** so clients discover updates |
| Offline | Shell/assets may load offline; API/chat/socket still need network |
| FCM web | `web/firebase-messaging-sw.js` — keep alongside Flutter’s SW; do not overwrite on deploy |

To debug without SW caching (force network):

```bash
# Prefer clearing site data in DevTools; or temporarily rename/remove
# flutter_service_worker.js after deploy (not recommended for production).
```

---

## SEO / meta

Configured in `web/index.html`:

- Title, description, keywords, theme-color
- Canonical / Open Graph / Twitter cards
- Apple web-app meta + touch icon
- Startup loading shell (removed on `flutter-first-frame`)

Canonical / OG URLs assume host `https://web.everqpid.com`. Change if the public host differs.

Google Sign-In web client ID is hardcoded in `index.html` (HTML cannot read `--dart-define`). Rotate both HTML meta and dart-define together.

---

## Browser compatibility

| Browser | Desktop | Mobile / tablet |
|---------|---------|-----------------|
| Chrome / Edge (Chromium) | Supported | Supported |
| Firefox | Supported | Supported |
| Safari | Supported (prefer recent macOS / iOS) | Supported; PWA install UX differs from Chromium |

Notes:

- Prefer **recent** browsers; CanvasKit needs WebAssembly + WebGL.
- Safari: private mode / ITP can affect storage; test Google Sign-In and cookies.
- Mobile: camera / mic permissions are browser-gated; some native plugins are limited (see below).

---

## Known web limitations

These are platform/plugin limits, not deployment bugs:

- **Audio recording** (`record`) — disabled on web in app code
- **Razorpay** — mobile plugin; payment UX may differ or be unavailable on web
- **Contacts** (`flutter_contacts`) — typically unavailable / limited on web
- **Facebook App Events** — skipped on web (`kIsWeb`)
- **Geolocation** — requires HTTPS + user permission
- **Push** — needs correct FCM web setup + `firebase-messaging-sw.js`
- **Camera selfie** — uses `image_picker` (file/camera picker); behavior varies by browser

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Refresh / deep link 404 | Nginx `try_files … /index.html` |
| Stale UI after deploy | `index.html` + `flutter_service_worker.js` must be `no-cache`; hard refresh or clear site data |
| White screen forever | Check browser console; confirm `flutter_bootstrap.js` and assets deploy; CORS/API errors can hang flows after paint |
| Google Sign-In fails | Match client ID in `index.html` + authorized JS origins for `web.everqpid.com` |
| MIME / WASM errors | Serve `.wasm` as `application/wasm`; enable gzip carefully for wasm if needed |
| Wrong base path | Rebuild with matching `--base-href=/subdir/` |

Local smoke test:

```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"  # only for local CORS debug
# Prefer:
flutter run -d chrome --dart-define=ENV=production
```

After deploy: open `/`, navigate to a nested route, refresh, use browser Back, open the same URL in a new tab.

---

## Checklist

- [ ] `flutter build web --release` succeeds
- [ ] Deploy full `build/web/`
- [ ] Nginx SPA fallback + cache headers
- [ ] HTTPS enabled
- [ ] Path URL refresh / deep link / back button verified
- [ ] PWA install (Chromium) smoke-tested
- [ ] Google Sign-In on production origin verified
